-- -----------------------------
-- 好声音枚举
-- hosr
-- -----------------------------
SingEumn = SingEumn or {}

-- 活动状态
-- 1:关闭 2:报名 3:准备投票 4:投票 5:准备决赛上传 6:决赛上传 7:准备决赛投票 8:决赛投票
SingEumn.ActiveState = {
    Close = 1,
    SignUp = 2,
    VotePre = 3,
    Vote = 4,
    FinalPre = 5,
    FinalSignUp = 6,
    FinalVotePre = 7,
    FinalVote = 8,
}

-- 歌曲状态
SingEumn.State = {
    Normal = 0, -- 普通
    Downloading = 1, -- 下载中
    Playing = 2, -- 播放中
}

