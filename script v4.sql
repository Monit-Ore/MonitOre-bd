-- =========================================================
-- BANCO DE DADOS MONITORE
-- =========================================================

CREATE DATABASE monitore;

USE monitore;

-- =========================================================
-- TABELA: EMPRESA
-- =========================================================

CREATE TABLE empresa (
    id_empresa INT PRIMARY KEY AUTO_INCREMENT,
    razao_social VARCHAR(200) NOT NULL,
    cnpj CHAR(14) NOT NULL,
    email VARCHAR(150) NOT NULL,
    tipo VARCHAR(45) NOT NULL
);


-- =========================================================
-- TABELA: FABRICANTE
-- =========================================================

CREATE TABLE fabricante (
    id_fabricante INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL
);


-- =========================================================
-- TABELA: ENDERECO
-- =========================================================

CREATE TABLE endereco (
    id_endereco INT PRIMARY KEY AUTO_INCREMENT,
    cep CHAR(8) NOT NULL,
    logradouro VARCHAR(200) NOT NULL,
    numero VARCHAR(20) NOT NULL,
    complemento VARCHAR(100),
    bairro VARCHAR(100) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    estado VARCHAR(80) NOT NULL
);


-- =========================================================
-- TABELA: TORRE
-- =========================================================

CREATE TABLE torre (
    id_torre INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    monitoramento_ativo TINYINT(1) NOT NULL DEFAULT 1,

    fk_fabricante INT NOT NULL,
    fk_endereco INT NOT NULL,
    fk_mineradora INT NOT NULL,

    CONSTRAINT fk_torre_fabricante
        FOREIGN KEY (fk_fabricante)
        REFERENCES fabricante(id_fabricante),

    CONSTRAINT fk_torre_endereco
        FOREIGN KEY (fk_endereco)
        REFERENCES endereco(id_endereco),

    CONSTRAINT fk_torre_empresa
        FOREIGN KEY (fk_mineradora)
        REFERENCES empresa(id_empresa)
);


-- =========================================================
-- TABELA: PC INDUSTRIAL
-- =========================================================

CREATE TABLE pc_industrial (
    id_pc_industrial INT PRIMARY KEY AUTO_INCREMENT,
    nome CHAR(36) NOT NULL,
    hostname VARCHAR(100) NOT NULL,
    status_operacional VARCHAR(20) NOT NULL,
    fk_torre INT NOT NULL,
    uuid VARCHAR(45) NOT NULL,

    CONSTRAINT fk_pc_torre
        FOREIGN KEY (fk_torre)
        REFERENCES torre(id_torre)
);


-- =========================================================
-- TABELA: COMPONENTE
-- =========================================================

CREATE TABLE componente (
    id_componente INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL
);


-- =========================================================
-- TABELA: LIMITE_ALERTA
-- =========================================================

CREATE TABLE limite_alerta (
    fk_pc_industrial INT NOT NULL,
    fk_componente INT NOT NULL,
    valor_limite DECIMAL(10,2) NOT NULL,

    PRIMARY KEY (fk_pc_industrial, fk_componente),

    CONSTRAINT fk_limite_pc
        FOREIGN KEY (fk_pc_industrial)
        REFERENCES pc_industrial(id_pc_industrial),

    CONSTRAINT fk_limite_componente
        FOREIGN KEY (fk_componente)
        REFERENCES componente(id_componente)
);


-- =========================================================
-- TABELA: USUARIO
-- =========================================================

CREATE TABLE usuario (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    cpf CHAR(11) NOT NULL,
    senha VARCHAR(100) NOT NULL,
    data_nascimento DATE NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    ultimo_acesso DATETIME,
    fk_empresa INT NOT NULL,
    cargo VARCHAR(100) NOT NULL,

    CONSTRAINT fk_usuario_empresa
        FOREIGN KEY (fk_empresa)
        REFERENCES empresa(id_empresa)
);


-- =========================================================
-- DADOS: EMPRESA
-- =========================================================

INSERT INTO empresa (
	razao_social,
    cnpj,
    email,
    tipo
) VALUES (
    'MonitOre Mineracao Ltda',
    '12345678000199',
    'contato@monitore.com',
    'MINERADORA'
);


-- =========================================================
-- DADOS: FABRICANTE
-- =========================================================

INSERT INTO fabricante (
    nome
) VALUES (
    'Siemens'
);


-- =========================================================
-- DADOS: ENDERECO
-- =========================================================

INSERT INTO endereco (
    cep,
    logradouro,
    numero,
    complemento,
    bairro,
    cidade,
    estado
) VALUES (
    '01001000',
    'Rua da Mineracao',
    '100',
    'Area Industrial',
    'Centro',
    'Belo Horizonte',
    'Minas Gerais'
);


-- =========================================================
-- DADOS: TORRE
-- =========================================================

INSERT INTO torre (
    nome,
    monitoramento_ativo,
    fk_fabricante,
    fk_endereco,
    fk_mineradora
) VALUES (
    'Torre de Extracao 01',
    1,
    1,
    1,
    1
);


-- =========================================================
-- DADOS: PC INDUSTRIAL
-- =========================================================

INSERT INTO pc_industrial (
    nome,
    hostname,
    status_operacional,
    fk_torre,
    uuid
) VALUES (
    'PC-INDUSTRIAL-01',
    'PC-IHM-SCADA-01',
    'ATIVO',
    1,
    '550e8400-e29b-41d4-a716-446655440000'
);


-- =========================================================
-- DADOS: COMPONENTES
-- =========================================================

INSERT INTO componente (
    nome
) VALUES
(
    'CPU'
),
(
    'RAM'
),
(
    'DISCO'
);

-- =========================================================
-- DADOS: USUÁRIOS
-- =========================================================

INSERT INTO usuario (
    nome,
    email,
    cpf,
    senha,
    data_nascimento,
    telefone,
    ultimo_acesso,
    fk_empresa,
    cargo
) VALUES
(
    'Administrador',
    'admin@monitore.com',
    '11111111111',
    '123456',
    '2000-01-15',
    '11999991111',
    NULL,
    1,
    'ADMIN'
),
(
    'Operador',
    'operador@monitore.com',
    '22222222222',
    '123456',
    '2001-05-20',
    '11999992222',
    NULL,
    1,
    'OPERADOR'
);
