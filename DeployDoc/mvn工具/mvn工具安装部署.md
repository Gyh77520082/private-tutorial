# Maven工具安装部署

## 一、下载

1. 新建文件夹，用于存放Maven的下载包：
    ```sh
    mkdir /usr/local/maven
    ```

2. 访问清华大学开源软件镜像站：
    [清华大学开源软件镜像站](https://mirrors.tuna.tsinghua.edu.cn/)

3. 找到并进入`apache`目录。

4. 进入`maven`目录。

5. 选择所需版本，外层为大版本，内层为小版本。

6. 进入`binaries`文件夹，选择压缩包（此处选择`apache-maven-3.6.3-bin.zip`）。

7. 使用`wget`命令下载Maven包：
    ```sh
    wget https://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.zip
    ```

8. 解压下载的包：
    ```sh
    unzip apache-maven-3.6.3-bin.zip
    ```
