* Make a new project folder

  ```js
  const fs = require('fs')
  fs.mkdirSync('project')
  ```

* Initialize a new repository

  ```js
  const repo = { fs, dir: 'project' }
  await git.init(repo)
  ```

* Create source files

  We can't help you here.
  This part you'll have to do on your own.