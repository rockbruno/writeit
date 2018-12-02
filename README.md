# WriteIt
💻 CLI static HTML page generator for blogs

Given a template `writeit_page_template.html` file containing an empty `id=writeit_dynamic_content` `div` and a list of content html files, WriteIt will generate HTML files with containing such contents surrounded by the template. This is used by https://swiftrocks.com to effortlessly publish a static website where all pages look the same:

<img src="https://i.imgur.com/UiNjggR.png" width=400><img src="https://i.imgur.com/DzWE9kz.png" width=400>

It can also be used to bootstrap new posts by automatically creating such content html files via the use of a `writeit_stub_template.html` that contains the shared basic structure of your posts:

``` html
<title>$writeit_post_name - My Blog</title>
<div id="header">
  <h1>$writeit_post_name</h1>
  <p>Created by Bruno Rocha</p>
</div>
//Write post here...
<h1>Conclusion</h1>
//Write conclusion here...
```

## Installation
Just download the latest release from this repo and paste it wherever you want the post generation to happen. You can also clone this repo and build it from source.

## Usage

(Note: There's an example website inside this repo if needed.)

Structure your folder like the following picture:

<img src="https://i.imgur.com/KyDHQr7.png" width=400>

`writeit_page_template.html` should contain the outside "shell" that's going to be applied to each page, with the actual dynamic section being completely empty and surrounded by a `writeit_dynamic_content` `div`:

``` html
<html>
  <body>
    <h3>My super blog</h3>
    <div id="writeit_dynamic_content"></div>
    <h3>Copyright John Doe</h3>
  </body>
</html>
```

`writeit_stub_template.html` is used for the creation of new posts, and should contain the basic structure of the content that's going to be inside the `writeit_dynamic_content` `div` like shown in the beginning of this README. You can use `$writeit_post_name` here to automatically apply the name of your new post (asked after running this tool). The stub will be stored at the `writeit-stubs` folder, which you should use to actually write your post.

After running WriteIt, you'll be able to choose whether to create a new post or generate the final HTML files. If the latter is chosen, a `public` folder will be created containing the finished pages.
