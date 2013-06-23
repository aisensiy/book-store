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

用户注册、登录，密码重置等，需要用图片验证码，保证安全性 # ~~缺乏那种权限控制~~
所有的书籍的展示页面，包括分类，以及各种排序 # 没有分类和排序, 也没有分页
单本书的展示页面 # 没有下载, 属性不齐全
书籍的上传，可以设置为用户私有和共有 # 上传表单要待改善
根据用户的浏览器语言，显示不同的语言，支持中文、英文和俄文。显示的语言书籍可选。比如用户可以同时显示英文和中文书，也可以只显示中文书。 # 国际化木有做
支持的类型有电子书、壁纸和应用，将来可能有其他的数据，可以有一张表用来保存所有的这些数据， # 目前只有电子书
提供推送，可以使用parse.com提供的推送api # 无
管理员界面，可以增删某些用户以及此用户上传的项目 # 无
