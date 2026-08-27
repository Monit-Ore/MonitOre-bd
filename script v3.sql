CREATE DATABASE IF NOT EXISTS monit_ore;

USE monit_ore;


CREATE TABLE empresa (
    id_empresa INT PRIMARY KEY AUTO_INCREMENT,

    razao_social VARCHAR(200) NOT NULL,
    cnpj CHAR(14) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,

    status_atividade VARCHAR(20) NOT NULL DEFAULT 'Ativo',

    CONSTRAINT chk_empresa_status
        CHECK (status_atividade IN ('Ativo', 'Inativo'))
);


CREATE TABLE mineradora (
    id_mineradora INT PRIMARY KEY AUTO_INCREMENT,

    razao_social VARCHAR(200) NOT NULL,
    cnpj CHAR(14) NOT NULL UNIQUE
);



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



CREATE TABLE permissao (
    id_permissao INT PRIMARY KEY AUTO_INCREMENT,

    nome VARCHAR(100) NOT NULL UNIQUE,
    descricao VARCHAR(250)
);



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



CREATE TABLE componente (
    id_componente INT PRIMARY KEY AUTO_INCREMENT,

    nome VARCHAR(100) NOT NULL UNIQUE,

    unidade_medida VARCHAR(20) NOT NULL
);



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