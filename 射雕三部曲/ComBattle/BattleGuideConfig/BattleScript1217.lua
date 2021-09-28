local BattleScript = {
    action = {
        [1] = {
            [1] = {
                file = "battle4.mp3",
                type = 10
            }
        },
        [2] = {
            [1] = {
                mapId = "guiyun.jpg",
                type = 0,
                x = 320,
                y = 568
            }
        },
        [3] = {
            [1] = {
                entryType = 8,
                heroId = 2,
                posId = 1,
                type = 2
            }
        },
        [4] = {
            [1] = {
                entryType = 8,
                heroId = 7,
                posId = 8,
                type = 2
            }
        },
        [5] = {
            [1] = {
                affect = {
                    [1] = {
                        effect = 2,
                        hp = -2852,
                        rage = 0,
                        toPos = 1
                    }
                },
                dead = {
                },
                fromPos = 8,
                rage = 50,
                skillId = 1002047,
                type = 7
            }
        },
        [6] = {
            [1] = {
                time = 0.1,
                type = 6
            }
        },
        [7] = {
            [1] = {
                chatType = 1,
                content_default = "今天我要讓你生不如死！",
                content_female = "",
                posId = 8,
                sound_default = "2050.mp3",
                sound_female = "",
				sound_tw = "2050_tw.mp3",
				sound_n_tw = "",
                type = 4
            }
        },
        [8] = {
            [1] = {
                entryType = 1,
                heroId = 1,
                posId = 2,
                type = 2
            }
        },
        [9] = {
            [1] = {
                chatType = 1,
                content_default = "住手！李莫愁！",
                content_female = "",
                posId = 2,
                sound_default = "2051.mp3",
                sound_female = "2051_n.mp3",
				sound_tw = "2051_tw.mp3",
				sound_n_tw = "2051_n_tw.mp3",
                type = 4
            }
        },
        [10] = {
            [1] = {
                chatType = 1,
                content_default = "陸姑娘，你傷勢很重，還是先離開這裏，我替你攔住她！",
                content_female = "",
                posId = 2,
                sound_default = "2052.mp3",
                sound_female = "2052_n.mp3",
				sound_tw = "2052_tw.mp3",
				sound_n_tw = "2052_n_tw.mp3",
                type = 4
            }
        },
        [11] = {
            [1] = {
                chatType = 1,
                content_default = "嗯！你也要多加小心！",
                content_female = "",
                posId = 1,
                sound_default = "2053.mp3",
                sound_female = "",
				sound_tw = "2053_tw.mp3",
				sound_n_tw = "",
                type = 4
            }
        },
        [12] = {
            [1] = {
                outType = 1,
                posId = 1,
                type = 3
            }
        },
        [13] = {
            [1] = {
                chatType = 1,
                content_default = "小賤人，還挺會勾引男人！剛走了一個楊過，這又勾搭上了一個！",
                content_female = "",
                posId = 8,
                sound_default = "2054.mp3",
                sound_female = "",
				sound_tw = "2054_tw.mp3",
				sound_n_tw = "",
                type = 4
            }
        },
        [14] = {
            [1] = {
                chatType = 1,
                content_default = "李莫愁！像你這種心腸惡毒的女人，換我是陸展元也不會要你!",
                content_female = "",
                posId = 2,
                sound_default = "2055.mp3",
                sound_female = "2055_n.mp3",
				sound_tw = "2055_tw.mp3",
				sound_n_tw = "2055_n_tw.mp3",
                type = 4
            }
        },
        [15] = {
            [1] = {
                chatType = 1,
                content_default = "你--！我要讓你--比那負心賊死得更慘！",
                content_female = "",
                posId = 8,
                sound_default = "2056.mp3",
                sound_female = "",
				sound_tw = "2056_tw.mp3",
				sound_n_tw = "",
                type = 4
            }
        },
        [16] = {
            [1] = {
                time = 0.2,
                type = 6
            }
        },
        [17] = {
            [1] = {
                affect = {
                    [1] = {
                        effect = 2,
                        hp = -1051,
                        rage = 0,
                        toPos = 2
                    }
                },
                dead = {
                },
                fromPos = 8,
                rage = -100,
                skillId = 1002047,
                type = 7
            }
        },
        [18] = {
            [1] = {
                affect = {
                    [1] = {
                        effect = 4,
                        hp = -324,
                        rage = 0,
                        toPos = 2
                    }
                },
                dead = {
                },
                fromPos = 8,
                rage = 100,
                skillId = 1001047,
                type = 7
            }
        },
        [19] = {
            [1] = {
                affect = {
                    [1] = {
                        effect = 2,
                        hp = -1400,
                        rage = 0,
                        toPos = 2
                    }
                },
                dead = {
                    [1] = 2
                },
                fromPos = 8,
                rage = -100,
                skillId = 1002047,
                type = 7
            }
        },
        [20] = {
        },
        [21] = {
        },
        [22] = {
        }
    },
    guider = true,
    hero = {
        [1] = {
            formationId = 1,
            name = "",
            quality = 0,
            scale = 1,
            type = 2
        },
        [2] = {
            cHP = 3000,
            cRP = 75,
            figureName = "hero_luwushuang",
            heroId = 12012402,
            mHP = 5000,
            name = "陸無雙",
            normalId = {
                [1] = 1001041
            },
            quality = 15,
            scale = 1,
            skillId = {
                [1] = 1002041
            },
            type = 0
        },
        [7] = {
            cHP = 8000,
            cRP = 75,
            figureName = "hero_limochou",
            heroId = 12012421,
            mHP = 8000,
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
            cHP = 1500,
            cRP = 75,
            figureName = "hero_yinliting",
            heroId = 0,
            mHP = 1500,
            name = "全真弟子",
            normalId = {
                [1] = 1001025
            },
            quality = 10,
            scale = 1,
            skillId = {
                [1] = 1002025
            },
            type = 0
        },
        [9] = {
            cHP = 1500,
            cRP = 75,
            figureName = "hero_zhaozhijing",
            heroId = 0,
            mHP = 1500,
            name = "護教弟子",
            normalId = {
                [1] = 1001030
            },
            quality = 10,
            scale = 1,
            skillId = {
                [1] = 1002030
            },
            type = 0
        },
        [10] = {
            cHP = 30000,
            cRP = 200,
            figureName = "hero_xiaoxiangzi",
            heroId = 0,
            mHP = 30000,
            name = "瀟湘子",
            normalId = {
                [1] = 1001045
            },
            quality = 15,
            scale = 1,
            skillId = {
                [1] = 1002045
            },
            type = 0
        },
        [11] = {
            cHP = 30000,
            cRP = 200,
            figureName = "hero_yikexi",
            heroId = 0,
            mHP = 30000,
            name = "尹克西",
            normalId = {
                [1] = 1001046
            },
            quality = 15,
            scale = 1,
            skillId = {
                [1] = 1002046
            },
            type = 0
        }
    }
}
return BattleScript