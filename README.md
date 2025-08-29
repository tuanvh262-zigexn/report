## How to run:

1. Clone the repo
  ```bash
  git clone git@github.com:ZIGExN-VeNtura/redmine-github-slack-automation.git
  ```

2. Update `Gemfile.lock`
  - If you use mac OS, go to step 3
  - If you use ubuntu, copy the content of file `Gemfile-ubuntu.lock` to `Gemfile.lock`
  ```bash
  cp Gemfile-ubuntu.lock Gemfile.lock
  ```

3. Start docker-compose:

  ```bash
  docker-compose build --no-cache
  docker-compose up
  ```

4. Access the root url: http://localhost:3000/sumai
