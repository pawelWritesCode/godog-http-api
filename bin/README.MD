Binary `user_crud` is web server (DOMAIN: _http://127.0.0.1:1234_) existing for github-actions testing purposes. Server has following endpoints:

| Method   | URI            | Body schema                                           |
| -------- | -------------- | ----------------------------------------------------  |
| POST     | /users         | {"firstName": string, "lastName": string, "age": int} |
| GET      | /users         | none                                                  |
| GET      | /users/:userId | none                                                  |
| PUT      | /users/:userId | {"firstName": string, "lastName": string, "age": int} |
| DELETE   | /users/:userId | none                                                  |


Entire directory `bin/` may be removed if necessary, but `features/test2.feature` will no longer pass.
