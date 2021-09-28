local BattleScript = {
    action = {
        [1] = {
            [1] = {
                file = "battle1.mp3",
                type = 10
            }
        },
        [2] = {
            [1] = {
                messageId = 101,
                type = 17
            }
        },
        [3] = {
            [1] = {
                messageId = 102,
                type = 17
            }
        },
        [4] = {
            [1] = {
                mapId = "zongnanshan.jpg",
                type = 0,
                x = 320,
                y = 568
            }
        },
        [5] = {
            [1] = {
                entryType = 1,
                heroId = 3,
                posId = 6,
                type = 2
            },
            [2] = {
                entryType = 1,
                heroId = 2,
                posId = 3,
                type = 2
            },
            [3] = {
                entryType = 1,
                heroId = 4,
                posId = 2,
                type = 2
            },
            [4] = {
                entryType = 1,
                heroId = 5,
                posId = 5,
                type = 2
            },
            [5] = {
                entryType = 1,
                heroId = 12,
                posId = 1,
                type = 2
            },
            [6] = {
                entryType = 1,
                heroId = 13,
                posId = 4,
                type = 2
            }
        },
        [6] = {
            [1] = {
                entryType = 2,
                heroId = 8,
                posId = 7,
                type = 2
            },
            [2] = {
                entryType = 2,
                heroId = 9,
                posId = 10,
                type = 2
            },
            [3] = {
                entryType = 2,
                heroId = 10,
                posId = 8,
                type = 2
            },
            [4] = {
                entryType = 2,
                heroId = 11,
                posId = 11,
                type = 2
            },
            [5] = {
                entryType = 2,
                heroId = 6,
                posId = 9,
                type = 2
            },
            [6] = {
                entryType = 2,
                heroId = 7,
                posId = 12,
                type = 2
            }
        },
        [7] = {
            [1] = {
                affect = {
                    [1] = {
                        effect = 4,
                        hp = 6524,
                        rage = 50,
                        toPos = 1
                    }
                },
                dead = {
                },
                fromPos = 7,
                rage = -100,
                skillId = 1002004,
                type = 7
            }
        },
        [8] = {
            [1] = {
                affect = {
                    [1] = {
                        effect = 4,
                        hp = 6562,
                        rage = 50,
                        toPos = 2
                    }
                },
                dead = {
                },
                fromPos = 8,
                rage = -100,
                skillId = 1002131,
                type = 7
            }
        },
        [9] = {
            [1] = {
                affect = {
                    [1] = {
                        effect = 4,
                        hp = -5154,
                        rage = 50,
                        toPos = 1
                    },
                    [2] = {
                        effect = 4,
                        hp = -5475,
                        rage = 50,
                        toPos = 2
                    },
                    [3] = {
                        effect = 2,
                        hp = -6582,
                        rage = 50,
                        toPos = 3
                    }
                },
                dead = {
                },
                fromPos = 9,
                rage = -100,
                skillId = 1002048,
                type = 7
            }
        },
        [10] = {
            [1] = {
                pos = 1,
                skillId = 1001001,
                type = 23
            }
        },
        [11] = {
            [1] = {
                affect = {
                    [1] = {
                        effect = 2,
                        hp = -6542,
                        rage = 25,
                        toPos = 7
                    },
                    [2] = {
                        effect = 2,
                        hp = -5841,
                        rage = 25,
                        toPos = 10
                    }
                },
                dead = {
                },
                fromPos = 1,
                rage = -100,
                skillId = 1002001,
                type = 7
            }
        },
        [12] = {
            [1] = {
                pos = 2,
                skillId = 1001114,
                type = 23
            }
        },
        [13] = {
            [1] = {
                affect = {
                    [1] = {
                        effect = 2,
                        hp = -3654,
                        rage = 10,
                        toPos = 8
                    },
                    [2] = {
                        effect = 2,
                        hp = -4215,
                        rage = 10,
                        toPos = 7
                    },
                    [3] = {
                        effect = 2,
                        hp = -4512,
                        rage = 10,
                        toPos = 9
                    }
                },
                dead = {
                },
                fromPos = 2,
                rage = -100,
                skillId = 1002114,
                type = 7
            }
        },
        [14] = {
            [1] = {
                pos = 3,
                skillId = 1002037,
                type = 23
            }
        },
        [15] = {
            [1] = {
                affect = {
                    [1] = {
                        effect = 2,
                        hp = -6526,
                        rage = 10,
                        toPos = 8
                    },
                    [2] = {
                        effect = 2,
                        hp = -6521,
                        rage = 10,
                        toPos = 7
                    },
                    [3] = {
                        effect = 2,
                        hp = -6581,
                        rage = 10,
                        toPos = 9
                    }
                },
                dead = {
                },
                fromPos = 3,
                rage = -100,
                skillId = 1002037,
                type = 7
            }
        },
        [16] = {
            [1] = {
                affect = {
                    [1] = {
                        effect = 2,
                        hp = -6215,
                        rage = 50,
                        toPos = 5
                    },
                    [2] = {
                        effect = 2,
                        hp = -7412,
                        rage = 50,
                        toPos = 6
                    },
                    [3] = {
                        effect = 2,
                        hp = -6254,
                        rage = 50,
                        toPos = 4
                    }
                },
                dead = {
                },
                fromPos = 10,
                rage = -100,
                skillId = 1002012,
                type = 7
            }
        },
        [17] = {
            [1] = {
                affect = {
                    [1] = {
                        effect = 2,
                        hp = -7524,
                        rage = 50,
                        toPos = 5
                    },
                    [2] = {
                        effect = 2,
                        hp = -7548,
                        rage = 50,
                        toPos = 6
                    },
                    [3] = {
                        effect = 2,
                        hp = -6254,
                        rage = 50,
                        toPos = 4
                    }
                },
                dead = {
                },
                fromPos = 11,
                rage = -100,
                skillId = 1002128,
                type = 7
            }
        },
        [18] = {
            [1] = {
                affect = {
                    [1] = {
                        effect = 4,
                        hp = -4536,
                        rage = 50,
                        toPos = 3
                    },
                    [2] = {
                        effect = 4,
                        hp = -4125,
                        rage = 50,
                        toPos = 2
                    },
                    [3] = {
                        effect = 4,
                        hp = -4524,
                        rage = 50,
                        toPos = 1
                    }
                },
                dead = {
                },
                fromPos = 12,
                rage = -100,
                skillId = 1002047,
                type = 7
            }
        },
        [19] = {
        },
        [20] = {
        },
        [21] = {
        },
        [22] = {
        },
        [23] = {
        },
        [24] = {
        },
        [25] = {
            [1] = {
                pos = {
                    [1] = 1,
                    [2] = 2,
                    [3] = 3
                },
                skillguide = 2,
                type = 8
            }
        },
        [26] = {
            [1] = {
                pos = 1,
                skillId = 1003001,
                type = 23
            }
        },
        [27] = {
            [1] = {
                affect = {
                    [1] = {
                        effect = 4,
                        hp = -4152,
                        rage = 0,
                        toPos = 7
                    },
                    [2] = {
                        effect = 2,
                        hp = -6652,
                        rage = 0,
                        toPos = 10
                    },
                    [3] = {
                        effect = 2,
                        hp = -6585,
                        rage = 25,
                        toPos = 8
                    },
                    [4] = {
                        effect = 2,
                        hp = -6585,
                        rage = 25,
                        toPos = 9
                    }
                },
                dead = {
                    [1] = 10
                },
                fromPos = 1,
                rage = -100,
                skillId = 1003001,
                type = 7
            }
        },
        [28] = {
            [1] = {
                pos = 2,
                skillId = 1003012,
                type = 23
            }
        },
        [29] = {
            [1] = {
                affect = {
                    [1] = {
                        effect = 2,
                        hp = -7632,
                        rage = 0,
                        toPos = 7
                    },
                    [2] = {
                        effect = 2,
                        hp = -6987,
                        rage = 0,
                        toPos = 8
                    },
                    [3] = {
                        effect = 2,
                        hp = -8653,
                        rage = 0,
                        toPos = 9
                    },
                    [4] = {
                        effect = 2,
                        hp = -6854,
                        rage = 0,
                        toPos = 11
                    }
                },
                dead = {
                    [1] = 11
                },
                fromPos = 2,
                rage = -100,
                skillId = 1003012,
                type = 7
            }
        },
        [30] = {
            [1] = {
                pos = 3,
                skillId = 1003020,
                type = 23
            }
        },
        [31] = {
            [1] = {
                affect = {
                    [1] = {
                        effect = 2,
                        hp = -34251,
                        rage = 0,
                        toPos = 7
                    },
                    [2] = {
                        effect = 2,
                        hp = -18976,
                        rage = 0,
                        toPos = 8
                    },
                    [3] = {
                        effect = 2,
                        hp = -34125,
                        rage = 0,
                        toPos = 9
                    },
                    [4] = {
                        effect = 2,
                        hp = -38452,
                        rage = 0,
                        toPos = 12
                    }
                },
                dead = {
                    [1] = 7,
                    [2] = 9,
                    [3] = 12
                },
                fromPos = 3,
                rage = -100,
                skillId = 1003020,
                type = 7
            }
        },
        [32] = {
            [1] = {
                time = 0.1,
                type = 6
            }
        },
        [33] = {
            [1] = {
                chatType = 1,
                content_default = "不！這……這不可能！我們這麼多人，怎麼會敗給你們！",
                content_female = "",
                posId = 8,
                sound_default = "k034.mp3",
                sound_female = "",
				sound_tw = "k034_tw.mp3",
				sound_n_tw = "",
                type = 4
            }
        },
        [34] = {
            [1] = {
                time = 0.1,
                type = 6
            }
        },
        [35] = {
            [1] = {
                outType = 2,
                posId = 8,
                type = 3
            }
        },
        [36] = {
            [1] = {
                time = 0.3,
                type = 6
            }
        },
        [37] = {
            [1] = {
                from = 2,
                to = 8,
                type = 1
            }
        },
        [38] = {
            [1] = {
                time = 0.3,
                type = 6
            }
        },
        [39] = {
            [1] = {
                posId = 8,
                type = 15
            },
            [2] = {
                time = 0.6,
                type = 6
            }
        },
        [40] = {
            [1] = {
                chatType = 1,
                content_default = "多謝諸位相助！不過歐陽鋒已經先我們一步，情況緊急，我們快些上山！",
                content_female = "",
                posId = 8,
                sound_default = "k035.mp3",
                sound_female = "",
				sound_tw = "k035_tw.mp3",
				sound_n_tw = "",
                type = 4
            }
        },
        [41] = {
            [1] = {
                time = 0.2,
                type = 6
            },
            [2] = {
                posId = 8,
                type = 15
            }
        },
        [42] = {
            [1] = {
                outType = 2,
                posId = 8,
                type = 3
            },
            [2] = {
                time = 0.4,
                type = 6
            }
        },
        [43] = {
            [1] = {
                outType = 2,
                posId = 1,
                type = 3
            },
            [2] = {
                outType = 2,
                posId = 3,
                type = 3
            },
            [3] = {
                outType = 2,
                posId = 4,
                type = 3
            },
            [4] = {
                outType = 2,
                posId = 5,
                type = 3
            },
            [5] = {
                outType = 2,
                posId = 6,
                type = 3
            }
        },
        [44] = {
            [1] = {
                messageId = 103,
                type = 17
            }
        },
        [45] = {
        }
    },
    guider = true,
    hero = {
        [1] = {
            formationId = 1,
            name = "",
            quality = 18,
            scale = 1,
            type = 2
        },
        [2] = {
            cHP = 20000,
            cRP = 100,
            figureName = "hero_yangguo",
            heroId = 12012301,
            mHP = 20000,
            name = "楊過",
            normalId = {
                [1] = 1001037
            },
            quality = 18,
            scale = 1,
            skillId = {
                [1] = 1002037,
                [2] = 1003020
            },
            type = 0
        },
        [3] = {
            cHP = 20000,
            cRP = 100,
            figureName = "hero_xiaolongnv",
            heroId = 12012302,
            mHP = 20000,
            name = "小龍女",
            normalId = {
                [1] = 1001038
            },
            quality = 18,
            scale = 1,
            skillId = {
                [1] = 1002038
            },
            type = 0
        },
        [4] = {
            cHP = 20000,
            cRP = 100,
            figureName = "hero_guojing",
            heroId = 12013301,
            mHP = 20000,
            name = "郭靖",
            normalId = {
                [1] = 1001114
            },
            quality = 18,
            scale = 1,
            skillId = {
                [1] = 1002114,
                [2] = 1003012
            },
            type = 0
        },
        [5] = {
            cHP = 20000,
            cRP = 100,
            figureName = "hero_huangrong",
            heroId = 12013302,
            mHP = 20000,
            name = "黃蓉",
            normalId = {
                [1] = 1001115
            },
            quality = 18,
            scale = 1,
            skillId = {
                [1] = 1002115
            },
            type = 0
        },
        [6] = {
            cHP = 30000,
            cRP = 100,
            figureName = "hero_jinlunfawang",
            heroId = 12012422,
            mHP = 30000,
            name = "金輪法王",
            normalId = {
                [1] = 1001048
            },
            quality = 15,
            scale = 1,
            skillId = {
                [1] = 1002048
            },
            type = 0
        },
        [7] = {
            cHP = 30000,
            cRP = 100,
            figureName = "hero_limochou",
            heroId = 12012421,
            mHP = 30000,
            name = "李莫愁",
            normalId = {
                [1] = 1001047
            },
            quality = 15,
            scale = 1,
            skillId = {
                [1] = 1002047
            },
            type = 0
        },
        [8] = {
            cHP = 30000,
            cRP = 100,
            figureName = "hero_zhaomin",
            heroId = 12011401,
            mHP = 30000,
            name = "趙敏",
            normalId = {
                [1] = 1001004
            },
            quality = 15,
            scale = 1,
            skillId = {
                [1] = 1002004
            },
            type = 0
        },
        [9] = {
            cHP = 30000,
            cRP = 100,
            figureName = "hero_fanyao",
            heroId = 12011422,
            mHP = 30000,
            name = "範遙",
            normalId = {
                [1] = 1001012
            },
            quality = 15,
            scale = 1,
            skillId = {
                [1] = 1002012
            },
            type = 0
        },
        [10] = {
            cHP = 30000,
            cRP = 100,
            figureName = "hero_ouyangke",
            heroId = 12013511,
            mHP = 30000,
            name = "歐陽克",
            normalId = {
                [1] = 1001131
            },
            quality = 15,
            scale = 1,
            skillId = {
                [1] = 1002131
            },
            type = 0
        },
        [11] = {
            cHP = 30000,
            cRP = 100,
            figureName = "hero_qiuqianren",
            heroId = 12013423,
            mHP = 30000,
            name = "裘千仞",
            normalId = {
                [1] = 1001128
            },
            quality = 15,
            scale = 1,
            skillId = {
                [1] = 1002128
            },
            type = 0
        },
        [12] = {
            cHP = 20000,
            cRP = 100,
            figureName = "hero_zhangwuji",
            heroId = 12011301,
            mHP = 20000,
            name = "張無忌",
            normalId = {
                [1] = 1001001
            },
            quality = 18,
            scale = 1,
            skillId = {
                [1] = 1002001,
                [2] = 1003001
            },
            type = 0
        },
        [13] = {
            cHP = 20000,
            cRP = 100,
            figureName = "hero_zhangsanfeng",
            heroId = 12011302,
            mHP = 20000,
            name = "張三豐",
            normalId = {
                [1] = 1001002
            },
            quality = 18,
            scale = 1,
            skillId = {
                [1] = 1002002
            },
            type = 0
        }
    }
}
return BattleScript