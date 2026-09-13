FROM python:3.10-bullseye

# expired となっている場合は Valid-Until を無視する
RUN apt-get -o Acquire::Check-Valid-Until=false update
# 以下のように archive.debian.org を使用するのは元のリポジトリで does not have a Release file のエラーが出てから（expired の対応としては適切ではなさそう）
# RUN    echo "deb http://archive.debian.org/debian bullseye main" > /etc/apt/sources.list \
#     && echo "deb http://archive.debian.org/debian-security bullseye-security main" >> /etc/apt/sources.list \
#     && echo "deb http://archive.debian.org/debian bullseye-updates main" >> /etc/apt/sources.list \
#     && apt-get update




CMD ["/bin/bash"]
