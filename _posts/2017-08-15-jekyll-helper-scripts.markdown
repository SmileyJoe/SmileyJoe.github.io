---
layout: post
title:  "Jekyll create post helper script"
date:   2017-08-15 23:29:12 +0200
categories: bash jekyll
---

Keep this little bash script in the root of your Jekyll site to quickly create a template for a new post.

## Script ##

Create a `.sh` file in your root, for example `new_post.sh` and poast the code below into it.

```bash
#!/bin/bash
header="---
layout: post
title:  
date:   $(date +%Y-%m-%d\ %H:%M:%S\ %z)
categories: 
---"
postdir="_posts"
filename="$postdir/$(date +%F)-$1.markdown"
echo "Creating $filename"
echo "$header" >> "$filename"
```

## Usage ##

In the terminal `cd` into your Jekyll site and run the script by passing in the title of the new post as a parameter.

```bash
./new_post.sh new-post-title
```