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
        
	descricao VARCHAR(255),

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
-- PLC
-- Cada torre possui no máximo uma PLC.
-- =========================================================

CREATE TABLE plc (
    id_plc INT PRIMARY KEY AUTO_INCREMENT,

    uuid_agente CHAR(36) UNIQUE,

    hostname VARCHAR(100),

    ip VARCHAR(45),

    sistema_operacional VARCHAR(100),

    status_operacional VARCHAR(20)
        NOT NULL DEFAULT 'Offline',

    ultima_comunicacao DATETIME,

    fk_torre INT NOT NULL UNIQUE,

    CONSTRAINT chk_plc_status
        CHECK (
            status_operacional IN (
                'Online',
                'Offline',
                'Alerta',
                'Manutenção'
            )
        ),

    CONSTRAINT fk_plc_torre
        FOREIGN KEY (fk_torre)
        REFERENCES torre(id_torre)
);


-- =========================================================
-- COMPONENTE
-- Tipo de componente monitorado pela PLC.
-- =========================================================

CREATE TABLE componente (
    id_componente INT PRIMARY KEY AUTO_INCREMENT,

    nome VARCHAR(100) NOT NULL UNIQUE,

    unidade_medida VARCHAR(20) NOT NULL
);


-- =========================================================
-- PLC E COMPONENTE
-- Relação N:N.
-- =========================================================

CREATE TABLE plc_componente (
    fk_plc INT NOT NULL,

    fk_componente INT NOT NULL,

    valor_limite DECIMAL(10, 2) NOT NULL,

    PRIMARY KEY (
        fk_plc,
        fk_componente
    ),

    CONSTRAINT chk_valor_limite
        CHECK (
            valor_limite >= 0
        ),

    CONSTRAINT fk_plc_componente_plc
        FOREIGN KEY (fk_plc)
        REFERENCES plc(id_plc),

    CONSTRAINT fk_plc_componente_componente
        FOREIGN KEY (fk_componente)
        REFERENCES componente(id_componente)
);

-- =========================================================
-- EQUIPE
-- Vai armazenar as informações da equipe que fez o projeto
-- =========================================================

CREATE TABLE equipe (
    id_equipe INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(17) NOT NULL,
    cargo VARCHAR(21) NOT NULL,
    descricao VARCHAR(75) NOT NULL,
    githubUrl VARCHAR(255) UNIQUE,
    linkedinUrl VARCHAR(255) UNIQUE,
    email VARCHAR(255) UNIQUE,
    caminhoFoto VARCHAR(255) NOT NULL UNIQUE
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
    'imgs/Equipe/LucasGama.jpg'
),
(
    'Thiago Emidio', 
    "Analista de Cloud", 
    'Analista de Cloud com virtualização na AWS', 
    'https://github.com/thiagoemidiosptech', 
    'https://www.linkedin.com/in/thiago-emidio-9974a638b/', 
    'thiago.souza@sptech.school', 
    'imgs/Equipe/thiago.jpg'
),
(
    'Nicole Rodrigues', 
    "Scrum Master", 
    'Scrum Master e analista de dados', 
    'https://github.com/nicky-rodrigues', 
    'https://www.linkedin.com/in/nicole-nascimento-8790763b8/', 
    'nicole.nascimento@sptech.school', 
    'imgs/Equipe/NicoleRodrigues.jpg'
),
(
    'Vinicius Borges', 
    "Full-stack", 
    'Desenvolvimento de páginas Web', 
    'https://github.com/vinicius-b-n', 
    'https://www.linkedin.com/in/vinicius-borges-a03743435/', 
    'vinicius.bnascimento@sptech.school', 
    'imgs/Equipe/Vinicius.jpg'
),
(
    'Guilherme Britto', 
    "Dev back-end", 
    'Desenvolvimento da integração do banco de dados', 
    'https://github.com/guilhermebrtt', 
    'https://www.linkedin.com/in/guilherme-britto-baa450312/', 
    'guilherme.britto@sptech.school', 
    'imgs/Equipe/GuilhermeBritto.jpg'
);


-- =========================================================
-- EMPRESA
-- Empresa fornecedora/monitoradora das torres (a própria Monit Ore).
-- =========================================================
 
INSERT INTO empresa (razao_social, cnpj, email, status_atividade) VALUES
('Monit Ore Soluções Industriais LTDA', '11222333000144', 'contato@monitore.com.br', 'Ativo');
 
 
-- =========================================================
-- MINERADORA
-- Clientes que recebem as torres (conforme o protótipo).
-- =========================================================
 
INSERT INTO mineradora (razao_social, cnpj) VALUES
('IBRAM', '22333444000155'),
('CSN Mineradora', '33444555000166'),
('Anglo America', '44555666000177');
 
 
-- =========================================================
-- ENDEREÇO DA MINERADORA
-- =========================================================
 
INSERT INTO endereco_mineradora
    (cep, logradouro, numero, complemento, bairro, cidade, estado, fk_mineradora)
VALUES
('35400000', 'Rodovia MG-262', 'KM 12', 'Galpão 3', 'Distrito Industrial', 'Ouro Preto', 'Minas Gerais', 1),
('25900000', 'Estrada do Minério', '850', NULL, 'Zona Rural', 'Volta Redonda', 'Rio de Janeiro', 2),
('35460000', 'Rodovia dos Inconfidentes', 'KM 45', 'Setor Norte', 'Área Rural', 'Conceição do Mato Dentro', 'Minas Gerais', 3);
 
 
-- =========================================================
-- TORRE
-- fk_empresa = 1 (Monit Ore) para todas.
-- Códigos únicos por empresa (padrão: sigla da mineradora + número).
-- =========================================================
 
-- IBRAM (fk_mineradora = 1)
INSERT INTO torre (nome, codigo, localizacao, status_operacional, monitoramento_ativo, fk_empresa, fk_mineradora) VALUES
('Torre 001', 'IBR-001', 'Setor de Britagem - Área 1', 'Operacional', TRUE, 1, 1),
('Torre 002', 'IBR-002', 'Pátio de Estocagem - Área 2', 'Alerta',      TRUE, 1, 1),
('Torre 003', 'IBR-003', 'Correia Transportadora 3',    'Alerta',      TRUE, 1, 1),
('Torre 004', 'IBR-004', 'Setor de Peneiramento',        'Alerta',      TRUE, 1, 1),
('Torre 005', 'IBR-005', 'Pátio de Estocagem - Área 5',  'Operacional', TRUE, 1, 1),
('Torre 006', 'IBR-006', 'Setor de Carregamento',        'Operacional', TRUE, 1, 1);
 
-- CSN Mineradora (fk_mineradora = 2)
INSERT INTO torre (nome, codigo, localizacao, status_operacional, monitoramento_ativo, fk_empresa, fk_mineradora) VALUES
('Torre 001', 'CSN-001', 'Britador Primário',            'Alerta',      TRUE, 1, 2),
('Torre 002', 'CSN-002', 'Correia Transportadora 1',      'Operacional', TRUE, 1, 2),
('Torre 003', 'CSN-003', 'Setor de Beneficiamento',       'Alerta',      TRUE, 1, 2),
('Torre 004', 'CSN-004', 'Pátio de Estocagem',            'Operacional', TRUE, 1, 2),
('Torre 005', 'CSN-005', 'Setor de Carregamento Ferroviário', 'Operacional', TRUE, 1, 2);
 
-- Anglo America (fk_mineradora = 3)
INSERT INTO torre (nome, codigo, localizacao, status_operacional, monitoramento_ativo, fk_empresa, fk_mineradora) VALUES
('Torre 001', 'ANG-001', 'Setor de Britagem Primária',    'Operacional', TRUE, 1, 3),
('Torre 002', 'ANG-002', 'Correia Transportadora 2',      'Operacional', TRUE, 1, 3),
('Torre 003', 'ANG-003', 'Pátio de Homogeneização',       'Operacional', TRUE, 1, 3),	
('Torre 004', 'ANG-004', 'Setor de Peneiramento',         'Operacional', TRUE, 1, 3),
('Torre 005', 'ANG-005', 'Barragem de Rejeitos',          'Alerta',      TRUE, 1, 3),
('Torre 006', 'ANG-006', 'Setor de Carregamento',         'Operacional', TRUE, 1, 3);
 
-- =========================================================
-- COMPONENTE
-- Fixos no sistema: CPU, RAM, Disco e Rede (todos em %).
-- id_componente gerado: 1=CPU, 2=RAM, 3=Disco, 4=Rede.
-- =========================================================
 
INSERT INTO componente (nome, unidade_medida) VALUES
('CPU', '%'), 
('RAM', '%'),
('Disco', '%'),
('Rede', '%');
 
 
-- =========================================================
-- PLC
-- Um PLC por torre (fk_torre é UNIQUE). Segue a mesma ordem
-- de criação das torres acima, então fk_torre = 1..17.
-- Torres com status 'Alerta' têm o PLC também em 'Alerta' e
-- com última comunicação mais antiga (indicando o problema).
-- =========================================================
 
INSERT INTO plc (uuid_agente, hostname, ip, sistema_operacional, status_operacional, ultima_comunicacao, fk_torre) VALUES
-- IBRAM
('SRV-IBR-001', 'plc-ibr-001', '10.10.1.11', 'Ubuntu Server 22.04', 'Online',  '2026-09-07 08:12:00', 1),
('SRV-IBR-002', 'plc-ibr-002', '10.10.1.12', 'Windows Server 2019', 'Alerta',  '2026-09-06 22:40:00', 2),
('SRV-IBR-003', 'plc-ibr-003', '10.10.1.13', 'Debian 12',           'Alerta',  '2026-09-06 22:55:00', 3),
('SRV-IBR-004', 'plc-ibr-004', '10.10.1.14', 'Ubuntu Server 20.04', 'Alerta',  '2026-09-06 23:05:00', 4),
('SRV-IBR-005', 'plc-ibr-005', '10.10.1.15', 'Ubuntu Server 22.04', 'Online',  '2026-09-07 08:14:00', 5),
('SRV-IBR-006', 'plc-ibr-006', '10.10.1.16', 'Windows Server 2022', 'Online',  '2026-09-07 08:16:00', 6),
-- CSN Mineradora
('SRV-CSN-001', 'plc-csn-001', '10.10.2.11', 'Debian 12',           'Alerta',  '2026-09-06 21:50:00', 7),
('SRV-CSN-002', 'plc-csn-002', '10.10.2.12', 'Ubuntu Server 22.04', 'Online',  '2026-09-07 08:20:00', 8),
('SRV-CSN-003', 'plc-csn-003', '10.10.2.13', 'Windows Server 2019', 'Alerta',  '2026-09-06 22:10:00', 9),
('SRV-CSN-004', 'plc-csn-004', '10.10.2.14', 'Ubuntu Server 20.04', 'Online',  '2026-09-07 08:22:00', 10),
('SRV-CSN-005', 'plc-csn-005', '10.10.2.15', 'CentOS Stream 9',     'Online',  '2026-09-07 08:24:00', 11),
-- Anglo America
('SRV-ANG-001', 'plc-ang-001', '10.10.3.11', 'Ubuntu Server 22.04', 'Online',  '2026-09-07 08:30:00', 12),
('SRV-ANG-002', 'plc-ang-002', '10.10.3.12', 'Windows Server 2022', 'Online',  '2026-09-07 08:32:00', 13),
('SRV-ANG-003', 'plc-ang-003', '10.10.3.13', 'Debian 12',           'Online',  '2026-09-07 08:34:00', 14),
('SRV-ANG-004', 'plc-ang-004', '10.10.3.14', 'Ubuntu Server 20.04', 'Online',  '2026-09-07 08:36:00', 15),
('SRV-ANG-005', 'plc-ang-005', '10.10.3.15', 'Windows Server 2019', 'Alerta',  '2026-09-06 21:15:00', 16),
('SRV-ANG-006', 'plc-ang-006', '10.10.3.16', 'Ubuntu Server 22.04', 'Online',  '2026-09-07 08:40:00', 17);
 
 
-- =========================================================
-- PLC_COMPONENTE
-- Métricas de alerta por PLC (CPU, RAM e Disco sempre; Rede
-- some para as torres em 'Alerta', que exigem mais monitoramento).
-- fk_ihm segue a mesma ordem/id da IHM inserida acima (1..17).
-- =========================================================
 
INSERT INTO plc_componente (fk_plc, fk_componente, valor_limite) VALUES
-- IBRAM
(1, 1, 85.00), (1, 2, 80.00), (1, 3, 90.00),
(2, 1, 90.00), (2, 2, 88.00), (2, 3, 92.00), (2, 4, 80.00),
(3, 1, 88.00), (3, 2, 85.00), (3, 3, 90.00), (3, 4, 75.00),
(4, 1, 92.00), (4, 2, 90.00), (4, 3, 95.00), (4, 4, 85.00),
(5, 1, 80.00), (5, 2, 75.00), (5, 3, 85.00),
(6, 1, 82.00), (6, 2, 78.00), (6, 3, 88.00),
-- CSN Mineradora
(7, 1, 90.00), (7, 2, 85.00), (7, 3, 93.00), (7, 4, 80.00),
(8, 1, 80.00), (8, 2, 76.00), (8, 3, 85.00),
(9, 1, 91.00), (9, 2, 87.00), (9, 3, 94.00), (9, 4, 82.00),
(10, 1, 78.00), (10, 2, 74.00), (10, 3, 84.00),
(11, 1, 83.00), (11, 2, 79.00), (11, 3, 86.00),
-- Anglo America
(12, 1, 80.00), (12, 2, 76.00), (12, 3, 85.00),
(13, 1, 82.00), (13, 2, 77.00), (13, 3, 87.00),
(14, 1, 79.00), (14, 2, 75.00), (14, 3, 84.00),
(15, 1, 81.00), (15, 2, 78.00), (15, 3, 86.00),
(16, 1, 93.00), (16, 2, 89.00), (16, 3, 96.00), (16, 4, 88.00),
(17, 1, 80.00), (17, 2, 76.00), (17, 3, 85.00);

-- Cargo do usuário, vinculado à empresa fabricante de torres (id 1).
INSERT INTO cargo (nome, descricao, status_atividade, fk_empresa)
VALUES ('Administrador', 'Acesso completo ao sistema de monitoramento', 'Ativo', 1);

-- Usuário de teste para login.
INSERT INTO usuario
  (nome, email, cpf, senha, data_nascimento, telefone, primeiro_acesso, status_atividade, fk_cargo, fk_mineradora)
VALUES (
  'João Silva',
  'joao.silva@monitore.com.br',
  '12345678900',
  'senha123',
  '1990-05-14',
  '31999998888',
  FALSE,
  'Ativo',
  (SELECT id_cargo FROM cargo WHERE nome = 'Administrador' AND fk_empresa = 1),
  NULL
);


