CREATE DATABASE monitOre;
USE monitOre;


-- =========================================================
-- EMPRESA
-- Empresa que contratou o sistema
-- =========================================================

CREATE TABLE empresa (
    id_empresa INT PRIMARY KEY AUTO_INCREMENT,
    razao_social VARCHAR(200) NOT NULL,
    cnpj CHAR(14) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,
    status_atividade VARCHAR(30) NOT NULL DEFAULT 'Ativo',
    dt_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT ch_empresa_status
        CHECK (status_atividade IN ('Ativo', 'Inativo'))
);


-- =========================================================
-- ENDEREÇO
-- Um endereço pode ser compartilhado por várias torres
-- =========================================================

CREATE TABLE endereco (
    id_endereco INT PRIMARY KEY AUTO_INCREMENT,
    cep CHAR(8) NOT NULL,
    logradouro VARCHAR(200) NOT NULL,
    numero VARCHAR(20) NOT NULL,
    bairro VARCHAR(100) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    estado VARCHAR(80) NOT NULL,
    pais VARCHAR(100) NOT NULL
);


-- =========================================================
-- CARGO
-- Cada empresa pode criar seus próprios cargos
-- =========================================================

CREATE TABLE cargo (
    id_cargo INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(250),
    status_atividade VARCHAR(30) NOT NULL DEFAULT 'Ativo',
    dt_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    fk_empresa INT NOT NULL,

    CONSTRAINT ch_cargo_status
        CHECK (status_atividade IN ('Ativo', 'Inativo')),

    CONSTRAINT fk_cargo_empresa
        FOREIGN KEY (fk_empresa)
        REFERENCES empresa(id_empresa),

    CONSTRAINT un_cargo_empresa
        UNIQUE (fk_empresa, nome)
);


-- =========================================================
-- PERMISSÃO
-- Permissões fixas disponibilizadas pelo sistema
-- =========================================================

CREATE TABLE permissao (
    id_permissao INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao VARCHAR(250)
);


-- =========================================================
-- CARGO_PERMISSAO
-- Resolve relacionamento N:N entre cargo e permissão
-- =========================================================

CREATE TABLE cargo_permissao (
    fk_cargo INT NOT NULL,
    fk_permissao INT NOT NULL,

    PRIMARY KEY (fk_cargo, fk_permissao),

    CONSTRAINT fk_cp_cargo
        FOREIGN KEY (fk_cargo)
        REFERENCES cargo(id_cargo),

    CONSTRAINT fk_cp_permissao
        FOREIGN KEY (fk_permissao)
        REFERENCES permissao(id_permissao)
);


-- =========================================================
-- USUÁRIO
-- Substitui a antiga tabela funcionario
-- =========================================================

CREATE TABLE usuario (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(200) NOT NULL,
    email VARCHAR(200) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,

    primeiro_acesso BOOLEAN NOT NULL DEFAULT TRUE,

    ultimo_acesso DATETIME,

    status_atividade VARCHAR(30) NOT NULL DEFAULT 'Ativo',

    dt_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    fk_cargo INT NOT NULL,

    CONSTRAINT ch_usuario_status
        CHECK (status_atividade IN ('Ativo', 'Inativo')),

    CONSTRAINT fk_usuario_cargo
        FOREIGN KEY (fk_cargo)
        REFERENCES cargo(id_cargo)
);


-- =========================================================
-- TORRE
-- Cada torre pertence a uma empresa e está associada
-- a um endereço.
--
-- Várias torres podem utilizar o mesmo endereço.
-- =========================================================

CREATE TABLE torre (
    id_torre INT PRIMARY KEY AUTO_INCREMENT,

    nome VARCHAR(100) NOT NULL,
    codigo VARCHAR(50) NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    descricao VARCHAR(250),

    -- Diferencia torres que ficam no mesmo endereço
    localizacao_interna VARCHAR(150),

    status_operacional VARCHAR(50) NOT NULL,

    criticidade VARCHAR(50) NOT NULL,

    dt_instalacao DATETIME,
    dt_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    fk_empresa INT NOT NULL,
    fk_endereco INT NOT NULL,

    CONSTRAINT ch_torre_status
        CHECK (
            status_operacional IN (
                'Operacional',
                'Manutenção',
                'Inativo'
            )
        ),

    CONSTRAINT ch_torre_criticidade
        CHECK (
            criticidade IN (
                'Baixa',
                'Média',
                'Alta',
                'Crítica'
            )
        ),

    CONSTRAINT fk_torre_empresa
        FOREIGN KEY (fk_empresa)
        REFERENCES empresa(id_empresa),

    CONSTRAINT fk_torre_endereco
        FOREIGN KEY (fk_endereco)
        REFERENCES endereco(id_endereco),

    -- Código precisa ser único dentro da empresa
    CONSTRAINT un_torre_empresa_codigo
        UNIQUE (fk_empresa, codigo)
);


-- =========================================================
-- TOKEN DE INSTALAÇÃO
-- Gerado após o cadastro da torre.
--
-- Serve para identificar a torre quando o agente for
-- instalado no servidor.
-- =========================================================

CREATE TABLE token_instalacao (
    id_token INT PRIMARY KEY AUTO_INCREMENT,

    token VARCHAR(255) NOT NULL UNIQUE,

    status_token VARCHAR(30) NOT NULL DEFAULT 'Ativo',

    dt_geracao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dt_expiracao DATETIME,
    dt_utilizacao DATETIME,

    fk_torre INT NOT NULL,

    CONSTRAINT ch_token_status
        CHECK (
            status_token IN (
                'Ativo',
                'Utilizado',
                'Expirado',
                'Revogado'
            )
        ),

    CONSTRAINT fk_token_torre
        FOREIGN KEY (fk_torre)
        REFERENCES torre(id_torre)
);


-- =========================================================
-- SERVIDOR
-- Criado automaticamente após o primeiro handshake
-- realizado pelo agente
-- =========================================================

CREATE TABLE servidor (
    id_servidor INT PRIMARY KEY AUTO_INCREMENT,

    -- Identificador gerado pelo agente
    uuid_agente CHAR(36) NOT NULL UNIQUE,

    hostname VARCHAR(100) NOT NULL,

    -- IP NÃO é UNIQUE, pois diferentes clientes podem
    -- utilizar os mesmos IPs privados
    ip VARCHAR(45) NOT NULL,

    sistema_operacional VARCHAR(100) NOT NULL,
    versao_so VARCHAR(50) NOT NULL,

    modelo_cpu VARCHAR(100) NOT NULL,
    memoria_total_gb INT NOT NULL,
    armazenamento_total_gb INT NOT NULL,

    status_operacional VARCHAR(30) NOT NULL DEFAULT 'Online',

    ultima_comunicacao DATETIME,

    versao_agente VARCHAR(50) NOT NULL,

    intervalo_coleta_segundos INT NOT NULL,

    dt_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    fk_torre INT NOT NULL,

    CONSTRAINT ch_servidor_status
        CHECK (
            status_operacional IN (
                'Online',
                'Offline',
                'Manutenção',
                'Inativo'
            )
        ),

    CONSTRAINT ch_intervalo_coleta
        CHECK (intervalo_coleta_segundos > 0),

    CONSTRAINT fk_servidor_torre
        FOREIGN KEY (fk_torre)
        REFERENCES torre(id_torre)
);