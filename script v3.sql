CREATE DATABASE IF NOT EXISTS monit_ore;

USE monit_ore;


-- =========================================================
-- EMPRESA
-- Empresa responsável por fornecer as torres.
-- =========================================================

CREATE TABLE empresa (
    id_empresa INT PRIMARY KEY AUTO_INCREMENT,

    razao_social VARCHAR(200) NOT NULL,
    cnpj CHAR(14) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,

    status_atividade VARCHAR(20)
        NOT NULL DEFAULT 'Ativo',

    CONSTRAINT chk_empresa_status
        CHECK (
            status_atividade IN (
                'Ativo',
                'Inativo'
            )
        )
);


-- =========================================================
-- MINERADORA
-- Empresa que recebe e utiliza as torres.
-- Também representa a unidade/local do funcionário.
-- =========================================================

CREATE TABLE mineradora (
    id_mineradora INT PRIMARY KEY AUTO_INCREMENT,

    razao_social VARCHAR(200) NOT NULL,
    cnpj CHAR(14) NOT NULL UNIQUE
);


-- =========================================================
-- ENDEREÇO DA MINERADORA
-- Uma mineradora possui um endereço.
-- Relação 1:1.
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
-- Cada cargo pertence a uma empresa.
-- =========================================================

CREATE TABLE cargo (
    id_cargo INT PRIMARY KEY AUTO_INCREMENT,

    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(250),

    status_atividade VARCHAR(20)
        NOT NULL DEFAULT 'Ativo',

    fk_empresa INT NOT NULL,

    CONSTRAINT chk_cargo_status
        CHECK (
            status_atividade IN (
                'Ativo',
                'Inativo'
            )
        ),

    CONSTRAINT fk_cargo_empresa
        FOREIGN KEY (fk_empresa)
        REFERENCES empresa(id_empresa),

    -- Impede cargos repetidos dentro da mesma empresa.
    CONSTRAINT uq_cargo_empresa_nome
        UNIQUE (
            fk_empresa,
            nome
        )
);


-- =========================================================
-- PERMISSÃO
-- Permissões disponíveis no sistema.
-- =========================================================

CREATE TABLE permissao (
    id_permissao INT PRIMARY KEY AUTO_INCREMENT,

    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao VARCHAR(250)
);


-- =========================================================
-- CARGO E PERMISSÃO
-- Relação N:N.
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
-- USUÁRIO
-- Funcionário que acessa o sistema.
-- A senha está em texto para o projeto local.
-- =========================================================

CREATE TABLE usuario (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,

    nome VARCHAR(200) NOT NULL,

    email VARCHAR(200) NOT NULL UNIQUE,

    cpf CHAR(11) NOT NULL UNIQUE,

    senha VARCHAR(255) NOT NULL,

    data_nascimento DATE,

    telefone VARCHAR(20),

    primeiro_acesso BOOLEAN
        NOT NULL DEFAULT TRUE,

    status_atividade VARCHAR(20)
        NOT NULL DEFAULT 'Ativo',

    ultimo_acesso DATETIME,

    fk_cargo INT NOT NULL,

    -- Unidade/local do funcionário.
    fk_mineradora INT,

    CONSTRAINT chk_usuario_status
        CHECK (
            status_atividade IN (
                'Ativo',
                'Inativo'
            )
        ),

    CONSTRAINT fk_usuario_cargo
        FOREIGN KEY (fk_cargo)
        REFERENCES cargo(id_cargo),

    CONSTRAINT fk_usuario_mineradora
        FOREIGN KEY (fk_mineradora)
        REFERENCES mineradora(id_mineradora)
);


-- =========================================================
-- TORRE
-- Torre fornecida pela empresa e instalada na mineradora.
-- =========================================================

CREATE TABLE torre (
    id_torre INT PRIMARY KEY AUTO_INCREMENT,

    nome VARCHAR(100) NOT NULL,

    codigo VARCHAR(50) NOT NULL,

    localizacao VARCHAR(150),

    status_operacional VARCHAR(30)
        NOT NULL DEFAULT 'Operacional',

    monitoramento_ativo BOOLEAN
        NOT NULL DEFAULT TRUE,

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

    -- O código é único dentro de cada empresa.
    CONSTRAINT uq_torre_empresa_codigo
        UNIQUE (
            fk_empresa,
            codigo
        )
);


-- =========================================================
-- IHM
-- Cada torre possui no máximo uma IHM.
-- =========================================================

CREATE TABLE ihm (
    id_ihm INT PRIMARY KEY AUTO_INCREMENT,

    uuid_agente CHAR(36) UNIQUE,

    hostname VARCHAR(100),

    ip VARCHAR(45),

    sistema_operacional VARCHAR(100),

    status_operacional VARCHAR(20)
        NOT NULL DEFAULT 'Offline',

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
-- Tipo de componente monitorado pela IHM.
-- =========================================================

CREATE TABLE componente (
    id_componente INT PRIMARY KEY AUTO_INCREMENT,

    nome VARCHAR(100) NOT NULL UNIQUE,

    unidade_medida VARCHAR(20) NOT NULL
);


-- =========================================================
-- IHM E COMPONENTE
-- Relação N:N.
-- =========================================================

CREATE TABLE ihm_componente (
    fk_ihm INT NOT NULL,

    fk_componente INT NOT NULL,

    valor_limite DECIMAL(10, 2) NOT NULL,

    PRIMARY KEY (
        fk_ihm,
        fk_componente
    ),

    CONSTRAINT chk_valor_limite
        CHECK (
            valor_limite >= 0
        ),

    CONSTRAINT fk_ihm_componente_ihm
        FOREIGN KEY (fk_ihm)
        REFERENCES ihm(id_ihm),

    CONSTRAINT fk_ihm_componente_componente
        FOREIGN KEY (fk_componente)
        REFERENCES componente(id_componente)
);

-- =========================================================
-- Membros da equipe de desenvolvimento
-- Tabela Informativa.
-- =========================================================

CREATE TABLE equipe (
    id_equipe INT NOT NULL,
    nome VARCHAR(17) NOT NULL,
    cargo VARCHAR(21) NOT NULL,
    descricao VARCHAR(75) NOT NULL,
    githubUrl VARCHAR(255) UNIQUE,
    linkedinUrl VARCHAR(255) UNIQUE,
    email VARCHAR(255) UNIQUE,
    caminhoFoto VARCHAR(255) NOT NULL UNIQUE,
    PRIMARY KEY (id_equipe)
);

INSERT INTO equipe (nome, cargo, descricao, githubUrl, linkedinUrl, email, caminhoFoto) 
VALUES 
(
    'Lucas Gama', 
    "Product Owner", 
    'Product Owner com bagagem técnica como Desenvolvedor Full Stack', 
    'https://github.com/Lucas-S-Gama', 
    'https://www.linkedin.com/in/lucas-gama-b724953b0/', 
    'lucas.gama@sptech.school', 
    'imgs/Equipe/LucasGama.png'
),
(
    'Thiago Emidio', 
    "", 
    '', 
    'https://github.com/', 
    'https://www.linkedin.com/in/', 
    '@sptech.school', 
    'imgs/Equipe/'
),
(
    'Nicole Rodrigues', 
    "", 
    '', 
    'https://github.com/', 
    'https://www.linkedin.com/in/', 
    '@sptech.school', 
    'imgs/Equipe/'
),
(
    'Vinicius Borges', 
    "", 
    '', 
    'https://github.com/', 
    'https://www.linkedin.com/in/', 
    '@sptech.school', 
    'imgs/Equipe/'
),
(
    'Guilherme Britto', 
    "", 
    '', 
    'https://github.com/', 
    'https://www.linkedin.com/in/', 
    '@sptech.school', 
    'imgs/Equipe/'
);

SELECT
nome,
cargo,
descricao,
githubUrl,
linkedinUrl,
email,
caminhoFoto
FROM equipe;