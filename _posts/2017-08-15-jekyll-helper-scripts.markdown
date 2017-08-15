---
layout: post
title:  Jekyll helper scripts
date:   2017-08-15 23:29:12 +0200
categories: bash
---

## New post ##

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