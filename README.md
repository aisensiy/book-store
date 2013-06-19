# books

Different orders

* books/:page  -- default with popular
* books/newest/:page
* books/popular/:page same as books/
* books/category/:category/:page
* books/:bookid -- a single book page
* books/new -- update a book

# users

* signup/
* signin/
* signout/
* accounts/password_modify/
* accounts/password_reset/

# upload

We use qiniu as storage. But the real data is set in parse.com.
We should first upload file to qiniu. After getting the feedback,
we send data to parse.com.
