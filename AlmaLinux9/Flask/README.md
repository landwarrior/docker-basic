# Flask のサンプル

AlmaLinux9 で Docker を起動した場合に Windows から Docker へのアクセスがうまくいかないのでその検証用です。  
SQL Server がうまくいっているので、これもうまくいくのでは、という想像です。

# docker build

VM に入ってから以下のコマンドを実行する

```bash
cd /vagrant/Flask
docker build -t flask .
```
