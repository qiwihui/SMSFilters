# SMSFilters

一个基于机器学习的 iOS 短信过滤 App。

## 训练模型

见 `model` 目录，依照 Jupyter Notebook 进行，可以使用 `conda` 安装环境：

```shell
$ cd model
# 创建环境
$ conda env create --file=environment.yml
```

## App

见 `iOS`，目前尚未完成。

### 功能列表

1. 主要
    - [x] 开启短信过滤功能（开启方式）
    - [ ] 准确性测试
    - [x] 提交短信

2. 自定义规则
    - [ ] 关键词黑名单
    - [ ] 关键词白名单
    - [ ] 号码黑名单
    - [ ] 号码白名单

3. 关于
    - [ ] 帮助和常见问题
    - [x] 隐私政策
    - [x] 向朋友推荐
    - [x] 软件评分
    - [x] 关于作者

### 界面截图

![主要界面](images/screenshot_main.png)
