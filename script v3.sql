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

    CONSTRAINT chk_ihm_status
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

    CONSTRAINT fk_ihm_componente_componente
        FOREIGN KEY (fk_componente)
        REFERENCES componente(id_componente)
);

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


INSERT INTO empresa (razao_social, cnpj, email) 
VALUES 
('Tech Towers Brasil Ltda', '12345678000199', 'contato@techtowers.com.br');

INSERT INTO mineradora (razao_social, cnpj) 
VALUES 
('Mineração Vale de Ouro S.A.', '98765432000188');

INSERT INTO endereco_mineradora (cep, logradouro, numero, complemento, bairro, cidade, estado, fk_mineradora) 
VALUES 
('35460000', 'Rodovia dos Minérios', 'S/N', 'KM 10 - Lote 5', 'Zona Rural', 'Brumadinho', 'MG', 1);

INSERT INTO cargo (nome, descricao, fk_empresa) 
VALUES 
('Administrador', 'Acesso total e gerenciamento do sistema', 1),
('Técnico de Campo', 'Monitoramento e manutenção das torres', 1);

INSERT INTO permissao (nome, descricao) 
VALUES 
('ALL_PRIVILEGES', 'Permissão total no sistema'),
('READ_ONLY', 'Apenas visualização dos dashboards e torres'),
('MAINTENANCE', 'Permissão para alterar status de manutenção das torres');

INSERT INTO cargo_permissao (fk_cargo, fk_permissao) 
VALUES 
(1, 1),
(2, 2),
(2, 3);

INSERT INTO usuario (nome, email, cpf, senha, data_nascimento, telefone, fk_cargo, fk_mineradora) 
VALUES 
('João Carlos', 'joao.carlos@techtowers.com', '11122233344', 'senha123', '1985-06-15', '11999998888', 1, 1),
('Maria Souza', 'maria.souza@techtowers.com', '55566677788', 'senha456', '1992-10-20', '31988887777', 2, 1);

INSERT INTO torre (nome, codigo, localizacao, status_operacional, fk_empresa, fk_mineradora) 
VALUES 
('Torre Norte Alpha', 'TN-001', 'Setor Norte - Mina 1', 'Operacional', 1, 1),
('Torre Sul Beta', 'TS-002', 'Setor Sul - Mina 1', 'Alerta', 1, 1);

INSERT INTO plc (uuid_agente, hostname, ip, sistema_operacional, status_operacional, fk_torre) 
VALUES 
('550e8400-e29b-41d4-a716-446655440000', 'plc-norte-01', '192.168.10.50', 'Linux Ubuntu 22.04', 'Online', 1),
('660e8400-e29b-41d4-a716-446655440001', 'plc-sul-02', '192.168.10.51', 'Linux Ubuntu 22.04', 'Manutenção', 2);

INSERT INTO componente (nome, unidade_medida) 
VALUES 
('CPU', '%'),
('Memória RAM', '%'),
('Disco', 'GB');

INSERT INTO ihm_componente (fk_plc, fk_componente, valor_limite) 
VALUES 
(1, 1, 85.00),
(1, 2, 90.00),
(2, 1, 85.00),
(2, 3, 50.00);

INSERT INTO usuario (nome, email, cpf, senha, data_nascimento, telefone, fk_cargo, fk_mineradora) 
VALUES 
('João Carl', 'joao.carlos2@techtowers.com', '11122233445', 'senha123', '1985-06-15', '11999998888', 1, 1);