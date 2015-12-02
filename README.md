# testiumjs Website

## Local Setup

Run the following to install jekyll:

~~~bash
bundle install
~~~

Then start the development server via:

~~~bash
bundle exec jekyll server
~~~

To update the deployed website,
just push to the master branch.


## Creating Pages

Files can be created as Markdown or HTML documents.
More information on authoring content can be found in the
[official Jekyll docs](http://jekyllrb.com/docs/home/).

Most pages should use the `sidebar` layout.


## Adding Pages to the Sidebar

The structure of the sidebar is configured via `_data/sidenav.yml`.
Example:

~~~yaml
  # This creates a top level heading that has no URL or content
- title: Section A
  items:
    # Each item in here appears under "Section A" and will be automatically
    # highlighted when the url matches the current page
  - url: /api.html
    title: API
    # You can also specify an `externalUrl`
  - externalUrl: 'https://example.com/some-url'
    title: Something External
- title: Section B
  items:
  - url: /generic-overview.html
    title: Overview of one aspect of B
    subitems:
    - url: /details.html
      title: More Specific Details
      # All urls are relativ to the project root, so the content for this page
      # would be generated in `nested/file.md`
    - url: /nested/file.html
      title: Even More Details
~~~
