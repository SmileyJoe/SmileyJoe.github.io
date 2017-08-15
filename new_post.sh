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
