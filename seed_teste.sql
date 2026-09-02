-- Seed de dados de teste para o banco da api-doacao (rode com psql/DBeaver
-- direto no Postgres usado pela API, depois de já ter aplicado database/schema.sql).
--
-- A API só cria automaticamente 5 usuários (admin/funcionario/voluntario,
-- senha "123456", via DataInitializer) — nenhum deles é doador, e não há
-- nenhuma ONG/campanha/categoria seedada. Este script cria o mínimo para
-- conseguir navegar e doar no app Doe+ logo após criar sua conta de doador
-- pela tela de cadastro do próprio app.

-- 1) Uma ONG de teste (sem usuário vinculado — só para o painel administrativo)
INSERT INTO ongs (razao_social, nome_fantasia, cnpj, email, telefone, cidade, estado, area_atuacao, chave_pix)
VALUES ('Instituto Mãos que Ajudam', 'Mãos que Ajudam', '12345678000199', 'contato@maosqueajudam.org',
        '19999990000', 'Americana', 'SP', 'Assistência social', 'contato@maosqueajudam.org');

-- 2) Duas campanhas ativas (uma financeira, uma material) ligadas a essa ONG
INSERT INTO campanhas (id_ong, tipo_campanha, titulo, descricao, objetivo, meta_financeira,
                        valor_arrecadado, data_inicio, data_fim, status, categoria, localizacao)
VALUES
  ((SELECT id_ong FROM ongs WHERE cnpj = '12345678000199'),
   'financeira', 'Campanha do Agasalho 2026',
   'Arrecadação de recursos para comprar roupas de inverno para famílias em situação de vulnerabilidade.',
   'Arrecadar R$5.000 até o fim do inverno', 5000.00, 0,
   CURRENT_DATE, CURRENT_DATE + INTERVAL '60 days', 'ativa', 'Agasalho', 'Americana - SP'),
  ((SELECT id_ong FROM ongs WHERE cnpj = '12345678000199'),
   'material', 'Doação de Alimentos',
   'Arrecadação de itens não perecíveis para famílias cadastradas na instituição.',
   'Montar 100 cestas básicas', NULL, 0,
   CURRENT_DATE, CURRENT_DATE + INTERVAL '45 days', 'ativa', 'Alimentos', 'Americana - SP');

-- 3) Categoria + itens doáveis (necessário para testar a doação material)
INSERT INTO categorias_doacao (nome, descricao) VALUES ('Alimentos', 'Itens de cesta básica');

INSERT INTO itens_doacao (id_categoria, nome, unidade_medida, perecivel)
VALUES
  ((SELECT id_categoria FROM categorias_doacao WHERE nome = 'Alimentos'), 'Arroz', 'kg', false),
  ((SELECT id_categoria FROM categorias_doacao WHERE nome = 'Alimentos'), 'Feijão', 'kg', false),
  ((SELECT id_categoria FROM categorias_doacao WHERE nome = 'Alimentos'), 'Leite', 'litro', true);
