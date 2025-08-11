---
# 🧩 Book ID
title: "{{ replace .Name "-" " " | title }}"
date: {{ .Date }}
weight: XX
draft: false
# 📘 Basic Info
author: ""
isbn: ""
published_year: 0
pages: 0
# Choose one
genre: "Imaginative Literature"
# or
genre: "Philosophy & Theology"
# or
genre: "History & Social Science"
# or
genre: "Science & Mathematics"
# or
genre: "Essays & Criticism"

language: ""
format: [] # "paperback", "ebook"
image: ""   # e.g. "images/books/gatsby.jpg"

# 🗓 Reading Timeline
start_date: {{ now.Format "2006-01-02" }}
end_date: ""
# duration: ""  # optional, can be auto-calculated

# 🌟 Evaluation
rating: 0       # 1 to 5
favorite: false
re_read: false
dnf: false

# 🧠 Reflection
summary: ""
themes: []

# 👥 Characters (key-value pairs or nested info if desired)
characters: {
  "Example Character": "Brief description or role"
}

# 🏷 Tags
tags: []

# 🧭 Suggested Tags (for reference only)
# Genre: fiction, non-fiction, fantasy, sci-fi, mystery
# Format: ebook, audiobook, paperback, hardcover
# Status: favorite, re-read, DNF
# Theme: justice, love, survival, identity, betrayal
# Mood: dark, lighthearted, intense, poetic
# Language: english, chinese, japanese

vocab: [

]
---

