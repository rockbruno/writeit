# Setup Instructions

(Check out the example folder in this repository for a complete and working example for what will be described below.)

WriteIt's initial setup is done in three steps:

1) Setting up the site data JSON
2) Setting up the page template file
3) Setting up the stub template file

## Setting up the site data JSON

The *Site Data* is a JSON describing the general metadata of your website. This is also used to generate your website's sitemap and RSS.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| domain |  The domain of your website.   |  none |
| name |  The website's display name.   |  none |
| output_path |  The path where to store any generated files.   |  none |
| description |  A short description of your website, to be used in RSS.   |  none |
| thumbnail_path |  The path to the thumbnail image that should be used for the generated SEO structured JSON object. At the moment, it's not possible to define different images for different URLs.  |  none |
| owner |  The name of the owner of the website.  |  none |
| copyright (optional) |  The website's copyright.  |  (current year + owner) |
| rss_name (optional) |  If provided, defines a custom name to be used for the RSS file specifically.  |  name field |
| rss_count (optional) |  The maximum number of entries that the RSS file should contain.  |  all pages |
| property_depth (optional) |  If one of your templates happens to contain "nested" WriteIt properties, increase this value to match the depth of the nesting. Otherwise, they will not be resolved properly.  |  2 |
| rss_div_cut_count (optional) |  If provided, WriteIt will skip the first X divs of a page when determining what should be included in the RSS entry for that page.   |  0 |

## Setting up the page template file

TODO
