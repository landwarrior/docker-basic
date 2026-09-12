FROM python:3.10-bullseye

# VM の時刻ずれで Release が expired と判定される場合があるため Valid-Until を無視する
# RUN apt-get -o Acquire::Check-Valid-Until=false update
# chronyd をインストールすると時刻がずれる問題が解消され Release の expired も出なくなるはず
RUN apt-get  update

CMD ["/bin/bash"]
