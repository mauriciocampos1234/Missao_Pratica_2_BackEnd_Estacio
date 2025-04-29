-- Criando o banco de dados
CREATE DATABASE loja;

--Criar um usuário "loja" com senha "loja"
CREATE USER loja WITH PASSWORD 'loja';

-- Dar permissões para o usuário "loja"
GRANT ALL PRIVILEGES ON DATABASE loja TO loja;

-- Criando uma Sequence para gerar o ID de Pessoa
CREATE SEQUENCE seq_pessoa_id
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
