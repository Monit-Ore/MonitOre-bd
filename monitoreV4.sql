CREATE DATABASE monitore;
USE monitore;

-- ============================================================
-- 1. TABELA EMPRESA
-- ============================================================

CREATE TABLE empresa (
    id_empresa INT PRIMARY KEY AUTO_INCREMENT,
    razao_social VARCHAR(200) NOT NULL,
    cnpj CHAR(14) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL,
    tipo VARCHAR(45) NOT NULL
);


-- ============================================================
-- 2. TABELA ENDERECO
-- ============================================================

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


-- ============================================================
-- 3. TABELA TORRE
-- ============================================================

CREATE TABLE torre (
    id_torre INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    codigo VARCHAR(100) NOT NULL,
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


-- ============================================================
-- 4. TABELA PC INDUSTRIAL
-- ============================================================

CREATE TABLE PC_Industrial (
    id_pc_industrial INT PRIMARY KEY AUTO_INCREMENT,
    nome CHAR(100) NOT NULL,
    hostname VARCHAR(100) NOT NULL UNIQUE,
    status_operacional VARCHAR(20) NOT NULL,
    fk_torre INT NOT NULL UNIQUE,
    uuid VARCHAR(45) NOT NULL UNIQUE,

    CONSTRAINT fk_pc_torre
        FOREIGN KEY (fk_torre)
        REFERENCES torre(id_torre)
);


-- ============================================================
-- 5. TABELA COMPONENTE
-- ============================================================

CREATE TABLE componente (
    id_componente INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL UNIQUE
);


-- ============================================================
-- 6. TABELA LIMITE_ALERTA
-- ============================================================

CREATE TABLE limite_alerta (
    fk_pc_industrial INT NOT NULL,
    fk_componente INT NOT NULL,
    atencao DECIMAL(10,2) NOT NULL,
    critico DECIMAL(10,2) NOT NULL,

    PRIMARY KEY (fk_pc_industrial, fk_componente),

    CONSTRAINT fk_limite_pc
        FOREIGN KEY (fk_pc_industrial)
        REFERENCES PC_Industrial(id_pc_industrial),

    CONSTRAINT fk_limite_componente
        FOREIGN KEY (fk_componente)
        REFERENCES componente(id_componente)
);


-- ============================================================
-- 7. TABELA USUARIO
-- ============================================================

CREATE TABLE usuario (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    cpf CHAR(11) NOT NULL UNIQUE,
    senha VARCHAR(100) NOT NULL,
    data_nascimento DATE,
    telefone VARCHAR(20),
    ultimo_acesso DATETIME,

    fk_empresa INT NOT NULL,

    cargo VARCHAR(100) NOT NULL,

    CONSTRAINT fk_usuario_empresa
        FOREIGN KEY (fk_empresa)
        REFERENCES empresa(id_empresa),

    CONSTRAINT chk_cargo
        CHECK (cargo IN ('Administrador', 'Operador'))
);

-- ============================================================
-- 8. TABELA PERMISSIONAMENTO
-- ============================================================

CREATE TABLE permissionamento (
    usuario_id_usuario INT NOT NULL,
    torre_id_torre INT NOT NULL,

    PRIMARY KEY (usuario_id_usuario, torre_id_torre),

    CONSTRAINT fk_permissionamento_usuario
        FOREIGN KEY (usuario_id_usuario)
        REFERENCES usuario(id_usuario),

    CONSTRAINT fk_permissionamento_torre
        FOREIGN KEY (torre_id_torre)
        REFERENCES torre(id_torre)
);



-- ============================================================
-- INSERINDO EMPRESAS
-- ============================================================

-- ============================================================
-- FABRICANTE
-- ============================================================

INSERT INTO empresa (
    razao_social,
    cnpj,
    email,
    tipo
)
VALUES (
    'MonitOre Sistemas Industriais Ltda.',
    '00000000000001',
    'contato@monitore.com.br',
    'Fabricante'
);


-- ============================================================
-- 10 MINERADORAS / CLIENTES
-- ============================================================

INSERT INTO empresa (
    razao_social,
    cnpj,
    email,
    tipo
)
VALUES
(
    'Vale S.A.',
    '33592510000154',
    'contato@vale.com',
    'Mineradora'
),

(
    'CSN Mineracao S.A.',
    '08189185000100',
    'contato@csn.com.br',
    'Mineradora'
),

(
    'Samarco Mineracao S.A.',
    '16628281000107',
    'contato@samarco.com',
    'Mineradora'
),

(
    'Anglo American Minerio de Ferro Brasil S.A.',
    '02359572000359',
    'contato@angloamerican.com',
    'Mineradora'
),

(
    'Gerdau Acos Longos S.A.',
    '07682289000166',
    'contato@gerdau.com',
    'Mineradora'
),

(
    'Mineracao Usiminas S.A.',
    '12345678000190',
    'contato@usiminas.com',
    'Mineradora'
),

(
    'Companhia Brasileira de Metalurgia e Mineracao',
    '12345678000271',
    'contato@cbmm.com',
    'Mineradora'
),

(
    'Nexa Recursos Minerais S.A.',
    '12345678000352',
    'contato@nexaresources.com',
    'Mineradora'
),

(
    'Mineracao Rio do Norte S.A.',
    '12345678000433',
    'contato@mrn.com.br',
    'Mineradora'
),

(
    'ArcelorMittal Brasil S.A.',
    '12345678000514',
    'contato@arcelormittal.com',
    'Mineradora'
);


-- ============================================================
-- ENDEREÇOS
-- ============================================================

INSERT INTO endereco (
    cep,
    logradouro,
    numero,
    complemento,
    bairro,
    cidade,
    estado
)
VALUES
(
    '35900000',
    'Avenida das Minas',
    '1000',
    NULL,
    'Centro',
    'Itabira',
    'Minas Gerais'
),

(
    '36415000',
    'Rodovia BR-040',
    '5000',
    'Unidade Industrial',
    'Zona Rural',
    'Congonhas',
    'Minas Gerais'
),

(
    '35420000',
    'Rodovia BR-262',
    '1200',
    'Unidade Operacional',
    'Zona Rural',
    'Mariana',
    'Minas Gerais'
),

(
    '35860000',
    'Avenida das Operacoes',
    '800',
    NULL,
    'Centro',
    'Conceicao do Mato Dentro',
    'Minas Gerais'
),

(
    '36420000',
    'Avenida Industrial',
    '1500',
    'Unidade Gerdau',
    'Distrito Industrial',
    'Ouro Branco',
    'Minas Gerais'
),

(
    '35685000',
    'Rodovia BR-381',
    '2200',
    NULL,
    'Zona Industrial',
    'Itatiaiucu',
    'Minas Gerais'
),

(
    '38183000',
    'Avenida Mineral',
    '700',
    NULL,
    'Distrito Industrial',
    'Araxá',
    'Minas Gerais'
),

(
    '38600000',
    'Rodovia MG-010',
    '3500',
    NULL,
    'Zona Rural',
    'Paracatu',
    'Minas Gerais'
),

(
    '68275000',
    'Rodovia PA-254',
    '100',
    NULL,
    'Zona Rural',
    'Porto Trombetas',
    'Pará'
),

(
    '29160000',
    'Avenida Siderurgia',
    '1800',
    NULL,
    'Distrito Industrial',
    'Serra',
    'Espírito Santo'
);


-- ============================================================
-- TORRES
--
-- Fabricante:
-- id_empresa = 1
--
-- Mineradoras:
-- Vale             = 2
-- CSN              = 3
-- Samarco          = 4
-- Anglo American   = 5
-- Gerdau           = 6
-- Usiminas         = 7
-- CBMM             = 8
-- Nexa             = 9
-- MRN              = 10
-- ArcelorMittal    = 11
--
-- 2 TORRES POR MINERADORA
-- TOTAL = 20 TORRES
-- ============================================================

INSERT INTO torre (
    nome,
    codigo,
    monitoramento_ativo,
    fk_fabricante,
    fk_endereco,
    fk_mineradora
)
VALUES

-- VALE
(
    'Torre Vale 01',
    'Torre-Vale-01',
    1,
    1,
    1,
    2
),

(
    'Torre Vale 02',
    'Torre-Vale-02',
    1,
    1,
    1,
    2
),

-- CSN
(
    'Torre CSN 01',
    'Torre-CSN-01',
    1,
    1,
    2,
    3
),

(
    'Torre CSN 02',
    'Torre-CSN-02',
    1,
    1,
    2,
    3
),

-- SAMARCO
(
    'Torre Samarco 01',
    'Torre-Samarco-01',
    1,
    1,
    3,
    4
),

(
    'Torre Samarco 02',
    'Torre-Samarco-02',
    1,
    1,
    3,
    4
),

-- ANGLO AMERICAN
(
    'Torre Anglo 01',
    'Torre-Anglo-01',
    1,
    1,
    4,
    5
),

(
    'Torre Anglo 02',
    'Torre-Anglo-02',
    1,
    1,
    4,
    5
),

-- GERDAU
(
    'Torre Gerdau 01',
    'Torre-Gerdau-01',
    1,
    1,
    5,
    6
),

(
    'Torre Gerdau 02',
    'Torre-Gerdau-02',
    1,
    1,
    5,
    6
),

-- USIMINAS
(
    'Torre Usiminas 01',
    'Torre-Usiminas-01',
    1,
    1,
    6,
    7
),

(
    'Torre Usiminas 02',
    'Torre-Usiminas-02',
    1,
    1,
    6,
    7
),

-- CBMM
(
    'Torre CBMM 01',
    'Torre-CBMM-01',
    1,
    1,
    7,
    8
),

(
    'Torre CBMM 02',
    'Torre-CBMM-02',
    1,
    1,
    7,
    8
),

-- NEXA
(
    'Torre Nexa 01',
    'Torre-Nexa-01',
    1,
    1,
    8,
    9
),

(
    'Torre Nexa 02',
    'Torre-Nexa-02',
    1,
    1,
    8,
    9
),

-- MRN
(
    'Torre MRN 01',
    'Torre-MRN-01',
    1,
    1,
    9,
    10
),

(
    'Torre MRN 02',
    'Torre-MRN-02',
    1,
    1,
    9,
    10
),

-- ARCELORMITTAL
(
    'Torre ArcelorMittal 01',
    'Torre-ArcelorMittal-01',
    1,
    1,
    10,
    11
),

(
    'Torre ArcelorMittal 02',
    'Torre-ArcelorMittal-02',
    1,
    1,
    10,
    11
);


-- ============================================================
-- PC INDUSTRIAL
--
-- 1 PC INDUSTRIAL PARA CADA TORRE
-- TOTAL = 20 PCS INDUSTRIAIS
-- ============================================================

INSERT INTO PC_Industrial (
    nome,
    hostname,
    status_operacional,
    fk_torre,
    uuid
)
VALUES

(
    'PC-INDUSTRIAL-000000000000000000000001',
    'PC-VALE-01',
    'Ativo',
    1,
    '550e8400-e29b-41d4-a716-000000000001'
),

(
    'PC-INDUSTRIAL-000000000000000000000002',
    'PC-VALE-02',
    'Ativo',
    2,
    '550e8400-e29b-41d4-a716-000000000002'
),

(
    'PC-INDUSTRIAL-000000000000000000000003',
    'PC-CSN-01',
    'Ativo',
    3,
    '550e8400-e29b-41d4-a716-000000000003'
),

(
    'PC-INDUSTRIAL-000000000000000000000004',
    'PC-CSN-02',
    'Ativo',
    4,
    '550e8400-e29b-41d4-a716-000000000004'
),

(
    'PC-INDUSTRIAL-000000000000000000000005',
    'PC-SAMARCO-01',
    'Ativo',
    5,
    '550e8400-e29b-41d4-a716-000000000005'
),

(
    'PC-INDUSTRIAL-000000000000000000000006',
    'PC-SAMARCO-02',
    'Ativo',
    6,
    '550e8400-e29b-41d4-a716-000000000006'
),

(
    'PC-INDUSTRIAL-000000000000000000000007',
    'PC-ANGLO-01',
    'Ativo',
    7,
    '550e8400-e29b-41d4-a716-000000000007'
),

(
    'PC-INDUSTRIAL-000000000000000000000008',
    'PC-ANGLO-02',
    'Ativo',
    8,
    '550e8400-e29b-41d4-a716-000000000008'
),

(
    'PC-INDUSTRIAL-000000000000000000000009',
    'PC-GERDAU-01',
    'Ativo',
    9,
    '550e8400-e29b-41d4-a716-000000000009'
),

(
    'PC-INDUSTRIAL-000000000000000000000010',
    'PC-GERDAU-02',
    'Ativo',
    10,
    '550e8400-e29b-41d4-a716-000000000010'
),

(
    'PC-INDUSTRIAL-000000000000000000000011',
    'PC-USIMINAS-01',
    'Ativo',
    11,
    '550e8400-e29b-41d4-a716-000000000011'
),

(
    'PC-INDUSTRIAL-000000000000000000000012',
    'PC-USIMINAS-02',
    'Ativo',
    12,
    '550e8400-e29b-41d4-a716-000000000012'
),

(
    'PC-INDUSTRIAL-000000000000000000000013',
    'PC-CBMM-01',
    'Ativo',
    13,
    '550e8400-e29b-41d4-a716-000000000013'
),

(
    'PC-INDUSTRIAL-000000000000000000000014',
    'PC-CBMM-02',
    'Ativo',
    14,
    '550e8400-e29b-41d4-a716-000000000014'
),

(
    'PC-INDUSTRIAL-000000000000000000000015',
    'PC-NEXA-01',
    'Ativo',
    15,
    '550e8400-e29b-41d4-a716-000000000015'
),

(
    'PC-INDUSTRIAL-000000000000000000000016',
    'PC-NEXA-02',
    'Ativo',
    16,
    '550e8400-e29b-41d4-a716-000000000016'
),

(
    'PC-INDUSTRIAL-000000000000000000000017',
    'PC-MRN-01',
    'Ativo',
    17,
    '550e8400-e29b-41d4-a716-000000000017'
),

(
    'PC-INDUSTRIAL-000000000000000000000018',
    'PC-MRN-02',
    'Ativo',
    18,
    '550e8400-e29b-41d4-a716-000000000018'
),

(
    'PC-INDUSTRIAL-000000000000000000000019',
    'PC-ARCELOR-01',
    'Ativo',
    19,
    '550e8400-e29b-41d4-a716-000000000019'
),

(
    'PC-INDUSTRIAL-000000000000000000000020',
    'PC-ARCELOR-02',
    'Ativo',
    20,
    '550e8400-e29b-41d4-a716-000000000020'
);


-- ============================================================
-- COMPONENTES
-- ============================================================

INSERT INTO componente (
    nome
)
VALUES
    ('CPU'),
    ('RAM'),
    ('DISCO');


-- ============================================================
-- LIMITES DE ALERTA
-- ============================================================

INSERT INTO limite_alerta (
    fk_pc_industrial,
    fk_componente,
    atencao,
    critico
)
VALUES

-- PC 01
(1, 1, 80.00, 90.00),
(1, 2, 80.00, 90.00),
(1, 3, 80.00, 90.00),

-- PC 02
(2, 1, 80.00, 90.00),
(2, 2, 80.00, 90.00),
(2, 3, 80.00, 90.00),

-- PC 03
(3, 1, 80.00, 90.00),
(3, 2, 80.00, 90.00),
(3, 3, 80.00, 90.00),

-- PC 04
(4, 1, 80.00, 90.00),
(4, 2, 80.00, 90.00),
(4, 3, 80.00, 90.00),

-- PC 05
(5, 1, 80.00, 90.00),
(5, 2, 80.00, 90.00),
(5, 3, 80.00, 90.00),

-- PC 06
(6, 1, 80.00, 90.00),
(6, 2, 80.00, 90.00),
(6, 3, 80.00, 90.00),

-- PC 07
(7, 1, 80.00, 90.00),
(7, 2, 80.00, 90.00),
(7, 3, 80.00, 90.00),

-- PC 08
(8, 1, 80.00, 90.00),
(8, 2, 80.00, 90.00),
(8, 3, 80.00, 90.00),

-- PC 09
(9, 1, 80.00, 90.00),
(9, 2, 80.00, 90.00),
(9, 3, 80.00, 90.00),

-- PC 10
(10, 1, 80.00, 90.00),
(10, 2, 80.00, 90.00),
(10, 3, 80.00, 90.00),

-- PC 11
(11, 1, 80.00, 90.00),
(11, 2, 80.00, 90.00),
(11, 3, 80.00, 90.00),

-- PC 12
(12, 1, 80.00, 90.00),
(12, 2, 80.00, 90.00),
(12, 3, 80.00, 90.00),

-- PC 13
(13, 1, 80.00, 90.00),
(13, 2, 80.00, 90.00),
(13, 3, 80.00, 90.00),

-- PC 14
(14, 1, 80.00, 90.00),
(14, 2, 80.00, 90.00),
(14, 3, 80.00, 90.00),

-- PC 15
(15, 1, 80.00, 90.00),
(15, 2, 80.00, 90.00),
(15, 3, 80.00, 90.00),

-- PC 16
(16, 1, 80.00, 90.00),
(16, 2, 80.00, 90.00),
(16, 3, 80.00, 90.00),

-- PC 17
(17, 1, 80.00, 90.00),
(17, 2, 80.00, 90.00),
(17, 3, 80.00, 90.00),

-- PC 18
(18, 1, 80.00, 90.00),
(18, 2, 80.00, 90.00),
(18, 3, 80.00, 90.00),

-- PC 19
(19, 1, 80.00, 90.00),
(19, 2, 80.00, 90.00),
(19, 3, 80.00, 90.00),

-- PC 20
(20, 1, 80.00, 90.00),
(20, 2, 80.00, 90.00),
(20, 3, 80.00, 90.00);


-- ============================================================
-- USUÁRIOS
-- ============================================================

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
)
VALUES

-- ============================================================
-- ADMINISTRADOR
-- ============================================================

(
    'Carlos Henrique Almeida',
    'carlos.almeida@monitore.com.br',
    '00000000001',
    '123456',
    '1990-05-15',
    '(11) 99999-1001',
    '2026-09-26 08:30:00',
    1,
    'Administrador'
),

-- ============================================================
-- OPERADORES
-- ============================================================

(
    'Mariana Souza Santos',
    'mariana.santos@monitore.com.br',
    '00000000002',
    '123456',
    '1995-03-22',
    '(11) 99999-1002',
    '2026-09-26 08:35:00',
    1,
    'Operador'
),

(
    'Rafael Oliveira Costa',
    'rafael.costa@monitore.com.br',
    '00000000003',
    '123456',
    '1993-07-10',
    '(11) 99999-1003',
    '2026-09-26 08:40:00',
    1,
    'Operador'
),

(
    'Juliana Martins Rocha',
    'juliana.rocha@monitore.com.br',
    '00000000004',
    '123456',
    '1997-11-05',
    '(11) 99999-1004',
    '2026-09-26 08:45:00',
    1,
    'Operador'
),

(
    'Lucas Ferreira Lima',
    'lucas.lima@monitore.com.br',
    '00000000005',
    '123456',
    '1994-01-18',
    '(11) 99999-1005',
    '2026-09-26 08:50:00',
    1,
    'Operador'
),

(
    'Amanda Rodrigues Silva',
    'amanda.silva@monitore.com.br',
    '00000000006',
    '123456',
    '1996-09-27',
    '(11) 99999-1006',
    '2026-09-26 08:55:00',
    1,
    'Operador'
),

(
    'Gabriel Pereira Mendes',
    'gabriel.mendes@monitore.com.br',
    '00000000007',
    '123456',
    '1992-12-03',
    '(11) 99999-1007',
    '2026-09-26 09:00:00',
    1,
    'Operador'
);


-- ============================================================
-- PERMISSIONAMENTO
-- ============================================================

INSERT INTO permissionamento (
    usuario_id_usuario,
    torre_id_torre
)
VALUES
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(1, 6),
(1, 7),
(1, 8),
(1, 9),
(1, 10),
(1, 11),
(1, 12),
(1, 13),
(1, 14),
(1, 15),
(1, 16),
(1, 17),
(1, 18),
(1, 19),
(1, 20),

(2, 1),
(2, 2),
(2, 3),
(2, 4),

(3, 5),
(3, 6),
(3, 7),
(3, 8),

(4, 9),
(4, 10),
(4, 11),

(5, 12),
(5, 13),
(5, 14),

(6, 15),
(6, 16),
(6, 17),

(7, 18),
(7, 19),
(7, 20);
