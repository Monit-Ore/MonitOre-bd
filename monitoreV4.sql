-- =========================================================
-- BANCO DE DADOS MONITORE
-- =========================================================

CREATE DATABASE monitore;
-- drop DATABASE monitore; 
USE monitore;




-- =========================================================
-- TABELA EMPRESA
-- =========================================================

CREATE TABLE empresa (
    id_empresa INT PRIMARY KEY AUTO_INCREMENT,
    razao_social VARCHAR(200) NOT NULL,
    cnpj CHAR(14) NOT NULL,
    email VARCHAR(150) NOT NULL,
    tipo VARCHAR(45) NOT NULL
);


-- =========================================================
-- TABELA ENDERECO
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
-- TABELA TORRE
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
        REFERENCES empresa(id_empresa),

    CONSTRAINT fk_torre_endereco
        FOREIGN KEY (fk_endereco)
        REFERENCES endereco(id_endereco),

    CONSTRAINT fk_torre_mineradora
        FOREIGN KEY (fk_mineradora)
        REFERENCES empresa(id_empresa)
);


-- =========================================================
-- TABELA PC INDUSTRIAL
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
-- TABELA COMPONENTE
-- =========================================================

CREATE TABLE componente (
    id_componente INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL
);


-- =========================================================
-- TABELA USUARIO
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
    cargo VARCHAR(100) NOT NULL
    CONSTRAINT chk_cargo
	CHECK (cargo IN ('ADMINISTRADOR', 'ANALISTA')),

    CONSTRAINT fk_usuario_empresa
        FOREIGN KEY (fk_empresa)
        REFERENCES empresa(id_empresa)
);


-- =========================================================
-- EMPRESAS
-- =========================================================

-- 1 = Fabricante
-- 2 = Mineradora

INSERT INTO empresa (
    razao_social,
    cnpj,
    email,
    tipo
) VALUES
(
    'TechMining Sistemas Industriais Ltda',
    '12345678000101',
    'contato@techmining.com.br',
    'FABRICANTE'
),
(
    'Mineradora Vale do Norte S.A.',
    '98765432000102',
    'contato@valedonorte.com.br',
    'MINERADORA'
);


-- =========================================================
-- ENDEREÇOS DAS TORRES
-- =========================================================

INSERT INTO endereco (
    cep,
    logradouro,
    numero,
    complemento,
    bairro,
    cidade,
    estado
) VALUES
(
    '30110000',
    'Rodovia da Mineracao',
    '1000',
    'Area Industrial - Torre 01',
    'Zona Industrial',
    'Belo Horizonte',
    'MG'
),
(
    '30120000',
    'Rodovia da Mineracao',
    '1500',
    'Area Industrial - Torre 02',
    'Zona Industrial',
    'Belo Horizonte',
    'MG'
),
(
    '30130000',
    'Estrada da Mina',
    '2000',
    'Area Industrial - Torre 03',
    'Zona Industrial',
    'Itabira',
    'MG'
),
(
    '30140000',
    'Estrada da Mina',
    '2500',
    'Area Industrial - Torre 04',
    'Zona Industrial',
    'Itabira',
    'MG'
),
(
    '30150000',
    'Rodovia Mineral',
    '3000',
    'Area Industrial - Torre 05',
    'Zona Industrial',
    'Congonhas',
    'MG'
);


-- =========================================================
-- TORRES
-- =========================================================

-- Fabricante = empresa 1
-- Mineradora = empresa 2

INSERT INTO torre (
    nome,
    monitoramento_ativo,
    fk_fabricante,
    fk_endereco,
    fk_mineradora
) VALUES
(
    'Torre de Extracao 01',
    1,
    1,
    1,
    2
),
(
    'Torre de Extracao 02',
    1,
    1,
    2,
    2
),
(
    'Torre de Extracao 03',
    1,
    1,
    3,
    2
),
(
    'Torre de Extracao 04',
    1,
    1,
    4,
    2
),
(
    'Torre de Extracao 05',
    1,
    1,
    5,
    2
);


-- =========================================================
-- PCS INDUSTRIAIS
-- =========================================================

INSERT INTO pc_industrial (
    nome,
    hostname,
    status_operacional,
    fk_torre,
    uuid
) VALUES
(
    'PC-INDUSTRIAL-01',
    'SCADA-TORRE-01',
    'ATIVO',
    1,
    '550e8400-e29b-41d4-a716-446655440001'
),
(
    'PC-INDUSTRIAL-02',
    'SCADA-TORRE-02',
    'ATIVO',
    2,
    '550e8400-e29b-41d4-a716-446655440002'
),
(
    'PC-INDUSTRIAL-03',
    'SCADA-TORRE-03',
    'ATIVO',
    3,
    '550e8400-e29b-41d4-a716-446655440003'
),
(
    'PC-INDUSTRIAL-04',
    'SCADA-TORRE-04',
    'ATIVO',
    4,
    '550e8400-e29b-41d4-a716-446655440004'
),
(
    'PC-INDUSTRIAL-05',
    'SCADA-TORRE-05',
    'ATIVO',
    5,
    '550e8400-e29b-41d4-a716-446655440005'
);


-- =========================================================
-- COMPONENTES
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
-- USUÁRIOS
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
    'ADMINISTRADOR'
),
(
    'Operador',
    'operador@monitore.com',
    '22222222222',
    '123456',
    '2001-05-20',
    '11999992222',
    NULL,
    2,
    'ANALISTA'
);