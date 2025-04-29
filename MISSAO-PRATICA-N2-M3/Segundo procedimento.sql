CREATE TABLE usuarios (
    id_usuario SERIAL PRIMARY KEY,
    login VARCHAR(50) NOT NULL UNIQUE,
    senha VARCHAR(50) NOT NULL
);

INSERT INTO usuarios (login, senha)
VALUES 
('op1', 'op1'),
('op2', 'op2');

CREATE TABLE produtos (
    id_produto SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    quantidade INTEGER NOT NULL,
    preco_venda NUMERIC(10,2) NOT NULL
);

INSERT INTO produtos (nome, quantidade, preco_venda)
VALUES 
('banana', 100, 5.00),
('laranja', 500, 2.00),
('manga', 800, 4.00);

CREATE TABLE pessoa (
    id_pessoa INTEGER PRIMARY KEY DEFAULT nextval('seq_pessoa_id'),
    nome VARCHAR(100) NOT NULL,
    endereco VARCHAR(150),
    telefone VARCHAR(20),
    email VARCHAR(100)
);

CREATE TABLE pessoa_fisica (
    id_pessoa INTEGER PRIMARY KEY,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    FOREIGN KEY (id_pessoa) REFERENCES pessoa(id_pessoa)
);

CREATE TABLE pessoa_juridica (
    id_pessoa INTEGER PRIMARY KEY,
    cnpj VARCHAR(18) NOT NULL UNIQUE,
    FOREIGN KEY (id_pessoa) REFERENCES pessoa(id_pessoa)
);

SELECT nextval('seq_pessoa_id');

INSERT INTO pessoa (id_pessoa, nome, endereco, telefone, email)
VALUES (1, 'João Silva', 'Rua das Flores, 123', '(11) 98765-4321', 'joao@email.com');

INSERT INTO pessoa_fisica (id_pessoa, cpf)
VALUES (1, '123.456.789-00');

INSERT INTO pessoa (id_pessoa, nome, endereco, telefone, email)
VALUES (2, 'Empresa XYZ Ltda.', 'Av. Central, 5000', '(11) 99876-5432', 'contato@empresa.com');

INSERT INTO pessoa_juridica (id_pessoa, cnpj)
VALUES (2, '12.345.678/0001-99');

CREATE TABLE movimentacoes (
    id_movimentacao SERIAL PRIMARY KEY,
    id_produto INTEGER NOT NULL,
    id_usuario INTEGER NOT NULL,
    tipo CHAR(1) NOT NULL, -- 'E' para Entrada (compra), 'S' para Saída (venda)
    quantidade INTEGER NOT NULL,
    preco_unitario NUMERIC(10,2) NOT NULL,
    data_movimentacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);

-- Entrada (Compra) de bananas
INSERT INTO movimentacoes (id_produto, id_usuario, tipo, quantidade, preco_unitario)
VALUES (1, 1, 'E', 100, 4.00);

-- Saída (Venda) de bananas
INSERT INTO movimentacoes (id_produto, id_usuario, tipo, quantidade, preco_unitario)
VALUES (1, 2, 'S', 30, 5.00);

-- Entrada (Compra) de laranjas
INSERT INTO movimentacoes (id_produto, id_usuario, tipo, quantidade, preco_unitario)
VALUES (2, 1, 'E', 500, 1.50);

-- Saída (Venda) de laranjas
INSERT INTO movimentacoes (id_produto, id_usuario, tipo, quantidade, preco_unitario)
VALUES (2, 2, 'S', 200, 2.00);

-- Entrada (Compra) de mangas
INSERT INTO movimentacoes (id_produto, id_usuario, tipo, quantidade, preco_unitario)
VALUES (3, 1, 'E', 800, 3.50);

INSERT INTO movimentacoes (id_produto, id_usuario, tipo, quantidade, preco_unitario)
VALUES (3, 2, 'S', 500, 4.00);

-- Consultas SQL conforme enunciado:

-- Dados completos de pessoas físicas
SELECT p.id_pessoa, p.nome, p.endereco, p.telefone, p.email, pf.cpf
FROM pessoa p
JOIN pessoa_fisica pf ON p.id_pessoa = pf.id_pessoa;

-- Dados completos de pessoas jurídicas
SELECT p.id_pessoa, p.nome, p.endereco, p.telefone, p.email, pj.cnpj
FROM pessoa p
JOIN pessoa_juridica pj ON p.id_pessoa = pj.id_pessoa;

-- Movimentações de entrada (compra):
-- . Produto
-- . Fornecedor (pessoa jurídica)
-- . Quantidade
-- . Preço unitário
-- . Valor total (quantidade × preço unitário)
SELECT 
    m.id_movimentacao,
    pr.nome AS produto,
    pe.nome AS fornecedor,
    m.quantidade,
    m.preco_unitario,
    (m.quantidade * m.preco_unitario) AS valor_total
FROM movimentacoes m
JOIN produtos pr ON m.id_produto = pr.id_produto
JOIN pessoa_juridica pj ON pj.id_pessoa = pj.id_pessoa
JOIN pessoa pe ON pj.id_pessoa = pe.id_pessoa
WHERE m.tipo = 'E';

-- Movimentações de saída (venda):
-- .Produto
-- .Comprador (pessoa física)
-- .Quantidade
-- .Preço unitário
-- .Valor total
SELECT 
    m.id_movimentacao,
    pr.nome AS produto,
    pe.nome AS comprador,
    m.quantidade,
    m.preco_unitario,
    (m.quantidade * m.preco_unitario) AS valor_total
FROM movimentacoes m
JOIN produtos pr ON m.id_produto = pr.id_produto
JOIN pessoa_fisica pf ON pf.id_pessoa = pf.id_pessoa
JOIN pessoa pe ON pf.id_pessoa = pe.id_pessoa
WHERE m.tipo = 'S';

-- Valor total das entradas agrupadas por produto:
SELECT 
    pr.nome AS produto,
    SUM(m.quantidade * m.preco_unitario) AS valor_total_entrada
FROM movimentacoes m
JOIN produtos pr ON m.id_produto = pr.id_produto
WHERE m.tipo = 'E'
GROUP BY pr.nome;

-- Valor total das saídas agrupadas por produto:
SELECT 
    pr.nome AS produto,
    SUM(m.quantidade * m.preco_unitario) AS valor_total_saida
FROM movimentacoes m
JOIN produtos pr ON m.id_produto = pr.id_produto
WHERE m.tipo = 'S'
GROUP BY pr.nome;

-- Operadores que não efetuaram movimentações de entrada (compra):
SELECT u.id_usuario, u.login
FROM usuarios u
WHERE u.id_usuario NOT IN (
    SELECT DISTINCT id_usuario
    FROM movimentacoes
    WHERE tipo = 'E'
);

-- Valor total de entrada agrupado por operador:
SELECT 
    u.login,
    SUM(m.quantidade * m.preco_unitario) AS valor_total_entrada
FROM movimentacoes m
JOIN usuarios u ON m.id_usuario = u.id_usuario
WHERE m.tipo = 'E'
GROUP BY u.login;

-- Valor total de saída agrupado por operador:
SELECT 
    u.login,
    SUM(m.quantidade * m.preco_unitario) AS valor_total_saida
FROM movimentacoes m
JOIN usuarios u ON m.id_usuario = u.id_usuario
WHERE m.tipo = 'S'
GROUP BY u.login;

-- Valor médio de venda por produto (média ponderada):
SELECT 
    pr.nome AS produto,
    SUM(m.quantidade * m.preco_unitario) / SUM(m.quantidade) AS media_ponderada_venda
FROM movimentacoes m
JOIN produtos pr ON m.id_produto = pr.id_produto
WHERE m.tipo = 'S'
GROUP BY pr.nome;



























