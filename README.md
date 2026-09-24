# Portfólio estático para GitHub Pages

Versão independente do portfólio Rails, preservando o visual original e implementada com HTML, CSS e JavaScript. Não precisa de Ruby, Rails, banco de dados, Docker, servidor de aplicação ou chave de API para funcionar.

O `index.html` já está gerado e contém os textos e documentos. Pode ser aberto diretamente no navegador. Os scripts Node são ferramentas opcionais de manutenção, testes e publicação; não são executados pelo site hospedado.

## Abrir e testar

Abra `index.html` nesta pasta. Para uma prévia por HTTP, com Node 20 ou superior:

```sh
cd my_portfolio_github_pages
npm start
```

Acesse `http://127.0.0.1:4173`. Não é necessário executar `npm install`, pois não há dependências de pacotes. Use `Ctrl+C` para encerrar a prévia.

Para simular um site de projeto publicado em uma subpasta:

```sh
npm start -- --base /meu-portfolio/ --port 4174
```

Acesse `http://127.0.0.1:4174/meu-portfolio/`. Todos os caminhos de CSS, JavaScript, foto e currículo são relativos.

## Publicar gratuitamente no GitHub Pages

Use um repositório público para o fluxo gratuito do GitHub Free. A publicação ainda não foi realizada por esta conversão.

### Opção A: repositório exclusivo para esta versão

1. Crie um repositório público no GitHub.
2. Coloque **o conteúdo desta pasta na raiz** desse repositório, incluindo os arquivos ocultos `.github`, `.gitignore` e `.nojekyll`. O `index.html` deve ficar na raiz, não dentro de outra pasta `my_portfolio_github_pages`.
3. Envie os arquivos para a branch `main`.
4. Em **Settings → Pages → Build and deployment → Source**, selecione **GitHub Actions**.
5. Em **Actions → Deploy static portfolio to GitHub Pages**, execute **Run workflow** na branch `main`. Os próximos pushes nessa branch executarão o mesmo fluxo automaticamente.

O workflow valida o HTML, executa os testes e publica somente `index.html`, `.nojekyll` e `assets/`. Não há instalação de dependências. O endereço publicado aparece na execução do workflow e em Settings → Pages.

### Opção B: manter esta pasta no repositório Rails existente

Os arquivos Rails podem continuar onde estão. O GitHub só reconhece workflows dentro de `.github/workflows/` **na raiz do repositório**.

Copie, sem substituir outros workflows:

```text
my_portfolio_github_pages/.github/workflows/pages.yml
    → .github/workflows/pages.yml
```

Essa cópia não foi feita automaticamente: todas as alterações desta tarefa ficaram dentro da pasta solicitada. Depois de copiar o workflow, selecione **GitHub Actions** em Settings → Pages e execute-o na branch `main`. Ele detecta `my_portfolio_github_pages` e publica apenas o conteúdo público dessa pasta.

Os workflows anteriores do Rails, incluindo deploy para o servidor antigo, não foram alterados. Eles continuam seguindo seus próprios gatilhos de execução; revise-os separadamente antes de enviar mudanças ao repositório antigo.

**Não selecione esta pasta na opção “Deploy from a branch”.** Essa modalidade oferece somente `/` ou `/docs` como pasta de origem. Para manter o nome `my_portfolio_github_pages`, use o workflow acima.

Se a branch principal não se chama `main`, ajuste tanto `on.push.branches` quanto a condição `jobs.deploy.if` no workflow.

### Alternativa sem workflow próprio

Em um repositório exclusivo, é possível publicar `index.html`, `assets/` e `.nojekyll` na raiz de uma branch e selecionar **Deploy from a branch → main → /(root)**. Não é necessário publicar `scripts/` ou `tests/`. O workflow fornecido é preferível quando os testes devem ser executados antes da publicação.

## O que foi preservado

O layout mantém os cartões, a identidade visual, o perfil em formato de código Ruby, as competências animadas, a linha do tempo e a localização do original. Tema claro/escuro e idioma português/inglês são controlados no navegador, com armazenamento opcional das preferências.

As seis visualizações de documentos continuam disponíveis: Sobre mim, Experiência, Competências, Destaques, Formação e Currículo. Os destaques têm busca sem distinção de acentos/maiúsculas e filtros por categoria. O currículo utiliza uma cópia local do PDF, com links para abrir e baixar, além de prévia em navegadores compatíveis.

As abas têm navegação por teclado. Os diálogos utilizam o elemento nativo `dialog`, suportam Escape, fechamento pelo fundo e retorno de foco. O CSS respeita a preferência de movimento reduzido. Sem JavaScript, os textos, documentos, links de contato e download continuam acessíveis; alternância de idioma/tema e filtros dependem de JavaScript.

## O que mudou por não existir backend

| No Rails | Na versão estática |
| --- | --- |
| Administração e conteúdo no banco | Edição do arquivo público `assets/js/content.js` |
| Envio automático de apresentação por e-mail | Link `mailto:` que abre o aplicativo de e-mail do visitante |
| Registro dos contatos recebidos | Removido; o site não coleta nem armazena contatos |
| Currículo servido por Active Storage | PDF local em `assets/documents/` |
| Traduções Rails/I18n | Dicionários PT/EN no arquivo de conteúdo |
| Controllers Stimulus/Turbo | JavaScript nativo, sem importmap e sem frameworks |
| Sincronização de projetos em background | Catálogo estático editável; sem consulta automática à API do GitHub |

O botão de contato **não envia e-mail automaticamente**, não anexa o PDF a uma mensagem e não mostra uma confirmação falsa de envio. Há um endereço de e-mail visível e um botão separado para baixar o currículo.

## Origem e limites do conteúdo migrado

Os textos e coleções foram extraídos de `db/seeds.rb`, com os rótulos de interface de `config/locales/pt.yml` e `config/locales/en.yml`. A foto e o currículo vieram dos arquivos públicos versionados. Foram importadas 12 competências, 3 experiências, 2 formações, 3 destaques e 6 documentos.

Foi possível conferir o perfil no banco local em modo somente leitura, mas a leitura das coleções do banco foi bloqueada pela ferramenta. Portanto, esta versão **não é um backup do servidor antigo nem uma exportação completa do banco local**. Alterações feitas exclusivamente no painel administrativo ou projetos sincronizados que não estejam em `db/seeds.rb` não foram recuperados. Revise o conteúdo antes de publicar e acrescente em `assets/js/content.js` o que estiver faltando.

Não foram copiados contatos recebidos, arquivos de banco, credenciais, variáveis de ambiente, configurações administrativas, chaves ou modelos internos de e-mail. Todo conteúdo publicado neste site é público; não inclua material sob NDA, dados privados ou segredos.

## Alterar textos, links e projetos

Edite `assets/js/content.js`. Ele concentra `profile`, `skills`, `experiences`, `educations`, `projects`, `documents` e os dicionários `messages.pt`/`messages.en`. Preserve as duas traduções nos campos localizados.

Um novo projeto pode seguir a estrutura abaixo, substituindo os textos e o endereço pelos dados reais:

```js
{
  id: "meu-projeto",
  metric: "Rails",
  titles: { pt: "Nome do projeto", en: "Project name" },
  descriptions: { pt: "Descrição em português.", en: "English description." },
  category: "project",
  category_color: "#a78bfa",
  primary_language: "Ruby",
  external_url: "https://github.com/USUARIO/REPOSITORIO",
  source: "github"
}
```

Categorias suportadas: `project`, `highlight` e `open_source`. Origens suportadas: `manual` e `github`. Essa origem é somente um rótulo; não ativa sincronização automática.

Para trocar o currículo ou a foto, substitua os arquivos correspondentes em `assets/` ou atualize `profile.resume`/`profile.avatar`. Use caminhos relativos, sem uma barra inicial.

Depois de alterar o conteúdo ou o renderer:

```sh
npm run build
npm test
npm run check
```

O build atualiza a versão pré-renderizada do `index.html`; isso mantém os textos acessíveis sem JavaScript. O teste de integridade detecta quando alguém altera `content.js` sem regenerar o HTML. Os testes que conferem os totais da migração devem ser atualizados quando você adicionar ou remover conteúdo intencionalmente.

`scripts/import-versioned-content.cjs` registra a importação inicial. Ele não é executado no deploy e não deve ser repetido para atualizar o site: recusa sobrescrever o arquivo de conteúdo existente.

## Arquivos principais

```text
index.html                          HTML completo já gerado
.nojekyll                           Desativa Jekyll na publicação por branch
.github/workflows/pages.yml         Workflow de validação e publicação
assets/css/application.css          CSS original do portfólio
assets/css/static.css               Ajustes da versão estática e acessibilidade
assets/js/content.js                Conteúdo público e traduções editáveis
assets/js/ui.js                     Renderização compartilhada navegador/build
assets/js/app.js                    Abas, diálogos, filtros, idioma e relógio
assets/js/theme-init.js             Tema antes da primeira renderização
assets/images/                      Foto local
assets/documents/                   Currículo PDF local
scripts/                            Ferramentas opcionais de manutenção
tests/                              Testes nativos Node, sem dependências
```

O CSS original importa Inter e JetBrains Mono do Google Fonts. Esse é o único serviço externo de apresentação; quando indisponível, o navegador utiliza as fontes locais de fallback. Para impedir inclusive essa requisição, remova a primeira linha `@import` de `assets/css/application.css`. Não há dependência externa de JavaScript, busca de conteúdo ou backend.

## Empacotar somente o site público

```sh
npm run package
```

A pasta `_site/` conterá apenas os arquivos para hospedagem. Ela é gerada e ignorada pelo Git. Para recriá-la quando já existir, use `npm run package -- --clean`, que substitui somente `_site/`. Não é necessário empacotar para abrir `index.html` localmente.

## Validação

`npm test` verifica conteúdo, paridade de traduções, renderização, escape de HTML, URLs seguras, filtros, IDs, âncoras, presença de todos os recursos, integridade básica do PDF e acesso HTTP na raiz e em `/example-repository/`. Os testes HTTP também verificam tipos de conteúdo, recursos inexistentes, proteção dos arquivos internos e redirecionamento de subpastas.

A validação visual em um navegador real não foi concluída nesta sessão: a ponte de navegador retornou erro de carregamento e o comando alternativo de navegador não estava permitido no ambiente. Os testes automatizados não substituem a revisão visual. Antes de publicar, confira as duas cores, os dois idiomas, as seis visualizações de documentos e o layout em celular.

O workflow foi preparado, mas a execução no GitHub Actions e o endereço publicado só podem ser verificados após configurar o repositório e executar o deploy. Nenhum commit, push ou publicação foi realizado automaticamente.

## Referências

- [Configurar a origem do GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site)
- [Criar um site GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-github-pages-site)
- [Usar workflows personalizados](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages)
