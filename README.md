# WriteIt
💻 CLI static HTML page generator for blogs

Given a template `writeit_page_template.html` file containing an empty `<div>` with identifier `WRITEIT_DYNAMIC_CONTENT` and a list of content html files, WriteIt will generate new HTML files with the contents of the template with the special `<div>` replaced with the contents of the content file. This is used by https://swiftrocks.com to effortlessly publish a static website where the pages all have the same appearance but content is different:

<img src="https://i.imgur.com/UiNjggR.png" width=400><img src="https://i.imgur.com/DzWE9kz.png" width=400>

WriteIt can also be used to bootstrap the creation of new blog posts given a `writeit_stub_template.html` file that contains the shared basic structure of your posts. Stubs support the creation of custom parameters that can be used to further customize the final generated page.

``` html
<!--Add here the additional properties that you want each page to possess.-->
<!--These properties can be used to change content in the template page or in the page itself as shown here.-->
<!--Properties must start with 'WRITEIT_POST'.-->
<!--Writeit provides and injects WRITEIT_POST_NAME and WRITEIT_POST_HTML_NAME by default.-->

<!--WRITEIT_POST_SHORT_DESCRIPTION-->

<title>$WRITEIT_POST_NAME - My Blog</title>
<div id="header">
  <h1>$WRITEIT_POST_NAME</h1>
  <p>Created by Bruno Rocha</p>
</div>
<p>$WRITEIT_POST_SHORT_DESCRIPTION</p>
<p>Write post here...</p
<h1>Conclusion</h1>
<p>Write conclusion here</p>
```

## Installation
Just download the latest release from this repo and paste it wherever you want the post generation to happen. You can also clone this repo and build it from source.

## Usage

(Note: This repo provides an example website if you're unsure how to make it work.)

Structure your folder like the following picture:

<img src="https://i.imgur.com/KyDHQr7.png" width=400>

`writeit_page_template.html` should contain the outside "shell" that's going to be applied to each page, with the actual dynamic section being completely empty and surrounded by a `WRITEIT_DYNAMIC_CONTENT` `<div>`. For customization purposes, the shell can also reference custom parameters from the stubs.

``` html
<html>
  <body>
    <h3>My super blog - Presenting $WRITEIT_POST_NAME</h3>
    <div id="WRITEIT_DYNAMIC_CONTENT"></div>
    <h3>Copyright John Doe</h3>
  </body>
</html>
```

`writeit_stub_template.html` is used for the creation of new posts, and should contain the basic structure of the content that's going to be inside the `WRITEIT_DYNAMIC_CONTENT` `<div>` like shown in the beginning of this README. The generated stub will be stored at the `writeit-stubs` folder, which should be used to write the actual post.

When running WriteIt, you'll be able to choose whether to bootstrap a new post or generate the final HTML files. If the latter is chosen, the finished pages will be stored in the `public` folder.
