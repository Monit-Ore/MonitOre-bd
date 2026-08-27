CREATE DATABASE IF NOT EXISTS monit_ore;

USE monit_ore;


-- =========================================================
-- EMPRESA
-- Cliente direto do Monitor Ore.
-- É a empresa responsável por fornecer as torres.
-- =========================================================

CREATE TABLE empresa (
    id_empresa INT PRIMARY KEY AUTO_INCREMENT,

    razao_social VARCHAR(200) NOT NULL,
    cnpj CHAR(14) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,

    status_atividade VARCHAR(20) NOT NULL DEFAULT 'Ativo',

    CONSTRAINT chk_empresa_status
        CHECK (status_atividade IN ('Ativo', 'Inativo'))
);


-- =========================================================
-- MINERADORA
-- Empresa que recebe/utiliza as torres.
-- Mantemos somente os dados essenciais de identificação.
-- =========================================================

CREATE TABLE mineradora (
    id_mineradora INT PRIMARY KEY AUTO_INCREMENT,

    razao_social VARCHAR(200) NOT NULL,
    cnpj CHAR(14) NOT NULL UNIQUE
);


-- =========================================================
-- ENDERECO_MINERADORA
-- Endereço básico da mineradora.
--
-- Relação 1:1:
-- uma mineradora possui um endereço.
-- =========================================================

CREATE TABLE endereco_mineradora (
    id_endereco INT PRIMARY KEY AUTO_INCREMENT,

    cep CHAR(8) NOT NULL,
    logradouro VARCHAR(200) NOT NULL,
    numero VARCHAR(20) NOT NULL,
    complemento VARCHAR(100),
    bairro VARCHAR(100) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    estado VARCHAR(80) NOT NULL,

    fk_mineradora INT NOT NULL UNIQUE,

    CONSTRAINT fk_endereco_mineradora
        FOREIGN KEY (fk_mineradora)
        REFERENCES mineradora(id_mineradora)
);


-- =========================================================
-- CARGO
-- Cargos criados/customizados por cada empresa.
--
-- Ex.:
-- Administrador
-- Operador
-- Técnico
-- Analista
-- =========================================================

CREATE TABLE cargo (
    id_cargo INT PRIMARY KEY AUTO_INCREMENT,

    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(250),

    fk_empresa INT NOT NULL,

    CONSTRAINT fk_cargo_empresa
        FOREIGN KEY (fk_empresa)
        REFERENCES empresa(id_empresa),

    -- Uma mesma empresa não pode ter dois cargos
    -- com exatamente o mesmo nome.
    CONSTRAINT uq_cargo_empresa_nome
        UNIQUE (fk_empresa, nome)
);


-- =========================================================
-- PERMISSAO
-- Permissões fixas existentes na aplicação.
--
-- Ex.:
-- Visualizar Dashboard
-- Cadastrar Usuário
-- Editar Usuário
-- Cadastrar Torre
-- Configurar Monitoramento
-- =========================================================

CREATE TABLE permissao (
    id_permissao INT PRIMARY KEY AUTO_INCREMENT,

    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao VARCHAR(250)
);


-- =========================================================
-- CARGO_PERMISSAO
-- Tabela associativa entre CARGO e PERMISSAO.
--
-- CARGO N:N PERMISSAO
-- =========================================================

CREATE TABLE cargo_permissao (
    fk_cargo INT NOT NULL,
    fk_permissao INT NOT NULL,

    PRIMARY KEY (
        fk_cargo,
        fk_permissao
    ),

    CONSTRAINT fk_cp_cargo
        FOREIGN KEY (fk_cargo)
        REFERENCES cargo(id_cargo),

    CONSTRAINT fk_cp_permissao
        FOREIGN KEY (fk_permissao)
        REFERENCES permissao(id_permissao)
);


-- =========================================================
-- USUARIO
-- Usuários que possuem acesso à plataforma.
--
-- A empresa do usuário pode ser descoberta através:
--
-- USUARIO -> CARGO -> EMPRESA
-- =========================================================

CREATE TABLE usuario (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,

    nome VARCHAR(200) NOT NULL,
    email VARCHAR(200) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,

    telefone VARCHAR(20),

    primeiro_acesso BOOLEAN NOT NULL DEFAULT TRUE,

    status_atividade VARCHAR(20) NOT NULL DEFAULT 'Ativo',

    ultimo_acesso DATETIME,

    fk_cargo INT NOT NULL,

    CONSTRAINT chk_usuario_status
        CHECK (
            status_atividade IN ('Ativo', 'Inativo')
        ),

    CONSTRAINT fk_usuario_cargo
        FOREIGN KEY (fk_cargo)
        REFERENCES cargo(id_cargo)
);


-- =========================================================
-- TORRE
--
-- A torre conecta:
--
-- EMPRESA     = quem forneceu a torre
-- MINERADORA  = onde a torre está instalada
--
-- O campo localizacao identifica onde a torre está
-- localizada dentro da operação da mineradora.
-- =========================================================

CREATE TABLE torre (
    id_torre INT PRIMARY KEY AUTO_INCREMENT,

    nome VARCHAR(100) NOT NULL,

    codigo VARCHAR(50) NOT NULL,

    localizacao VARCHAR(150),

    status_operacional VARCHAR(30) NOT NULL DEFAULT 'Operacional',

    monitoramento_ativo BOOLEAN NOT NULL DEFAULT TRUE,

    fk_empresa INT NOT NULL,
    fk_mineradora INT NOT NULL,

    CONSTRAINT chk_torre_status
        CHECK (
            status_operacional IN (
                'Operacional',
                'Alerta',
                'Manutenção',
                'Inativo'
            )
        ),

    CONSTRAINT fk_torre_empresa
        FOREIGN KEY (fk_empresa)
        REFERENCES empresa(id_empresa),

    CONSTRAINT fk_torre_mineradora
        FOREIGN KEY (fk_mineradora)
        REFERENCES mineradora(id_mineradora),

    -- O código precisa ser único dentro da empresa.
    CONSTRAINT uq_torre_empresa_codigo
        UNIQUE (
            fk_empresa,
            codigo
        )
);


-- =========================================================
-- IHM
-- Computador/IHM instalado na torre e monitorado
-- pelo agente do Monitor Ore.
--
-- Relação:
-- TORRE 1 -> 0..1 IHM
--
-- O UNIQUE em fk_torre impede duas IHMs
-- de serem associadas à mesma torre.
-- =========================================================

CREATE TABLE ihm (
    id_ihm INT PRIMARY KEY AUTO_INCREMENT,

    uuid_agente CHAR(36) UNIQUE,

    hostname VARCHAR(100),

    ip VARCHAR(45),

    sistema_operacional VARCHAR(100),

    status_operacional VARCHAR(20) NOT NULL DEFAULT 'Offline',

    ultima_comunicacao DATETIME,

    fk_torre INT NOT NULL UNIQUE,

    CONSTRAINT chk_ihm_status
        CHECK (
            status_operacional IN (
                'Online',
                'Offline',
                'Alerta',
                'Manutenção'
            )
        ),

    CONSTRAINT fk_ihm_torre
        FOREIGN KEY (fk_torre)
        REFERENCES torre(id_torre)
);


-- =========================================================
-- COMPONENTE
-- Catálogo de componentes/métricas que podem ser
-- monitorados.
--
-- Exemplos:
--
-- CPU   | %
-- RAM   | %
-- Disco | %
-- =========================================================

CREATE TABLE componente (
    id_componente INT PRIMARY KEY AUTO_INCREMENT,

    nome VARCHAR(100) NOT NULL UNIQUE,

    unidade_medida VARCHAR(20) NOT NULL
);


-- =========================================================
-- IHM_COMPONENTE
--
-- Tabela ASSOCIATIVA entre IHM e COMPONENTE.
--
-- IHM N:N COMPONENTE
--
-- Também guarda o parâmetro específico daquela relação.
--
-- Exemplo:
--
-- IHM 1 + CPU   = 80%
-- IHM 1 + RAM   = 60%
-- IHM 1 + Disco = 75%
--
-- IHM 2 + CPU   = 70%
-- IHM 2 + RAM   = 70%
-- =========================================================

CREATE TABLE ihm_componente (
    fk_ihm INT NOT NULL,
    fk_componente INT NOT NULL,

    valor_limite DECIMAL(10,2) NOT NULL,

    PRIMARY KEY (
        fk_ihm,
        fk_componente
    ),

    CONSTRAINT chk_valor_limite
        CHECK (valor_limite >= 0),

    CONSTRAINT fk_ihm_componente_ihm
        FOREIGN KEY (fk_ihm)
        REFERENCES ihm(id_ihm),

    CONSTRAINT fk_ihm_componente_componente
        FOREIGN KEY (fk_componente)
        REFERENCES componente(id_componente)
);