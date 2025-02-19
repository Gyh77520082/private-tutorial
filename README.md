# 本仓库提交规范指南

## 一、引言

在团队协作开发中，遵循Git提交规范是非常重要的。它不仅有助于保持代码库的可读性和可维护性，还能提高代码审查的效率。

## 二、提交前缀规范

### 2.1 常用提交类型前缀

- **feat**：表示新增功能或页面。
- **fix**：表示修复bug、解决冲突。
- **modify**：表示修改现有功能。
- **delete**：表示删除功能或文件。
- **docs**：表示修改文档。
- **refactor**：表示代码重构，未新增功能或修复bug。
- **build**：表示改变构建流程或添加依赖库。
- **style**：表示格式化代码，如空格、缩进等。
- **perf**：表示性能优化。
- **chore**：表示非核心代码的修改，如构建脚本或辅助工具。
- **test**：表示测试用例的添加或修改。
- **ci**：表示持续集成相关的更改。
- **revert**：表示回滚到之前的版本。

## 三、示例

```sh
git commit -m "[feat]: 新增用户登录功能"
git commit -m "[fix]: 修复用户登录bug"
git commit -m "[docs]: 更新README文档"
git commit -m "[style]: 格式化代码"
```



