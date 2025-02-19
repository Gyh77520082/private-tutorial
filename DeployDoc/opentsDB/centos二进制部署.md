# OpenTSDB说明

OpenTSDB是依赖于HBase进行数据存储的，所以在安装OpenTSDB组件之前，需要已经部署了HBase组件。

## 1. 安装HBase前期工作

OpenTSDB 是基于HBase的，HBase需要安装JDK。

**① 安装前的清理工作（非必要操作）**

```bash
rpm -qa | grep jdk
rpm -qa | grep gcj
yum -y remove java-xxx-xxx
```

**② 下载JDK对应版本包**
官网下载JDK: [https://www.oracle.com/cn/java/technologies/downloads/](https://www.oracle.com/cn/java/technologies/downloads/)
这里下载的是 `jdk-8u391-linux-x64.rpm`，将文件上传至服务器上，并添加可执行权限：

```bash
chmod +x jdk-8u391-linux-x64.rpm
rpm -ivh jdk-8u391-linux-x64.rpm
```

查看JDK是否安装成功：

```bash
java -version
```

查看JDK的安装路径（一般默认路径：`/usr/java/jdk1.8.0-x64`）。

**③ 配置JDK环境变量**
编辑 `/etc/profile` 文件，在尾部插入以下配置信息：

```bash
export JAVA_HOME=/usr/java/jdk1.8.0-x64  # 注意修改为实际的JDK安装路径
export JRE_HOME=${JAVA_HOME}/jre
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib:$CLASSPATH
export JAVA_PATH=${JAVA_HOME}/bin:${JRE_HOME}/bin
export PATH=$PATH:${JAVA_PATH}
```

执行命令使配置文件生效：

```bash
source /etc/profile
```

**④ 安装HBase**
官网下载地址：[https://hbase.apache.org/downloads.html](https://hbase.apache.org/downloads.html)（这里下载的是二进制包）。

```bash
tar -xzvf hbase-2.2.4-bin.tar.gz
```

编辑 `conf/hbase-env.sh` 文件，取消注释 `#export JAVA_HOME=` 行，并设置为Java安装路径：

```bash
export JAVA_HOME=/usr/java/jdk1.8.0-x64
```

编辑 `conf/hbase-site.xml` 文件，添加以下配置信息：

```xml
<property>
  <name>hbase.rootdir</name>
  <value>file:///data/HBase/hbase-2.5.7/hbase</value> <!-- hbase实际存放数据地方，生产环境一般为HDFS地址 -->
</property>
<property>
  <name>hbase.zookeeper.property.dataDir</name>
  <value>/data/HBase/hbase-2.5.7/zookeeper</value>
</property>
```

启动HBase服务：

```bash
cd bin/
./start-hbase.sh
```

使用 `jps` 命令查看HBase是否启动成功。

为了方便，可以将HBase加入环境变量中，在 `/etc/profile` 文件中增加以下内容：

```bash
export HBASE_HOME=/root/opentsdb/hbase-2.5.7
export PATH=$HBASE_HOME/bin:$PATH
source /etc/profile
```

## 2. 安装配置并启动OpenTSDB

官网下载地址：[http://opentsdb.net/](http://opentsdb.net/)
下载最新版本包，这里选择下载 `rpm` 源文件进行安装，地址：[https://github.com/OpenTSDB/opentsdb/releases](https://github.com/OpenTSDB/opentsdb/releases)

```bash
rpm -ivh opentsdb-2.4.1-1-20210902183110-root.noarch.rpm
```

OpenTSDB安装之后的目录介绍：

```
/etc/opentsdb                            —— 配置文件目录
/usr/share/opentsdb                      —— 应用程序目录
/usr/share/opentsdb/bin                  —— "tsdb"启动脚本目录
/usr/share/opentsdb/lib                  —— Java JAR library
/usr/share/opentsdb/plugins              —— 插件和依赖
/usr/share/opentsdb/static               —— GUI 静态文件
/usr/share/opentsdb/tools                —— 脚本和其他工具
/var/log/opentsdb                        —— 日志存放目录
```

**① HBase创建对应表**
第一次运行OpenTSDB实例时，需要先创建HBase表，OpenTSDB已经提供了创建脚本：

```bash
env COMPRESSION=NONE HBASE_HOME=/root/opentsdb/hbase-2.5.7 /usr/share/opentsdb/tools/create_table.sh
```

验证：

```bash
cd /root/opentsdb/hbase-2.5.7/bin
./hbase shell
list
```

**② 修改 `/etc/opentsdb/opentsdb.conf` 配置文件**
注意：默认OpenTSDB配置文件目录：`/etc/opentsdb/opentsdb.conf`，默认OpenTSDB日志目录：`/var/log/opentsdb`

```properties
tsd.storage.hbase.zk_quorum = localhost:2181  # zookeeper的地址
```

**③ 启动OpenTSDB服务**

```bash
/usr/share/opentsdb/etc/init.d/opentsdb start
```

启动之后，可以通过 `http://xx.xx.xx.xx:4242` 访问 TSD 的web界面。
