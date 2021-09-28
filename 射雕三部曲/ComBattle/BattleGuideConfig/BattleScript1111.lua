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
                messageId = 10011,
                type = 17
            }
        },
        [3] = {
            [1] = {
                mapId = "zongnanshan.jpg",
                type = 0,
                x = 320,
                y = 568
            }
        },
        [4] = {
            [1] = {
                entryType = 8,
                heroId = 2,
                posId = 2,
                type = 2
            }
        },
        [5] = {
            [1] = {
                entryType = 8,
                heroId = 10,
                posId = 8,
                type = 2
            },
            [2] = {
                entryType = 8,
                heroId = 8,
                posId = 7,
                type = 2
            },
            [3] = {
                entryType = 8,
                heroId = 9,
                posId = 9,
                type = 2
            }
        },
        [6] = {
            [1] = {
                affect = {
                    [1] = {
                        effect = 2,
                        hp = -552,
                        rage = 0,
                        toPos = 2
                    }
                },
                dead = {
                },
                fromPos = 8,
                rage = 50,
                skillId = 1001026,
                type = 7
            }
        },
        [7] = {
        },
        [8] = {
            [1] = {
                messageId = 10012,
                type = 17
            }
        },
        [9] = {
            [1] = {
                entryType = 1,
                heroId = 1,
                posId = 1,
                type = 2
            }
        },
        [10] = {
            [1] = {
                messageId = 10013,
                type = 17
            }
        },
        [11] = {
            [1] = {
                affect = {
                    [1] = {
                        effect = 4,
                        hp = -63,
                        rage = 50,
                        toPos = 1
                    }
                },
                dead = {
                },
                fromPos = 8,
                rage = -100,
                skillId = 1002026,
                type = 7
            }
        },
        [12] = {
            [1] = {
                affect = {
                    [1] = {
                        effect = 4,
                        hp = -25,
                        rage = 50,
                        toPos = 1
                    }
                },
                dead = {
                },
                fromPos = 7,
                rage = -100,
                skillId = 1002025,
                type = 7
            }
        },
        [13] = {
            [1] = {
                affect = {
                    [1] = {
                        effect = 2,
                        hp = -321,
                        rage = 0,
                        toPos = 2
                    }
                },
                dead = {
                },
                fromPos = 9,
                rage = -100,
                skillId = 1001030,
                type = 7
            }
        },
        [14] = {
            [1] = {
                affect = {
                    [1] = {
                        effect = 2,
                        hp = -1254,
                        rage = 0,
                        toPos = 7
                    },
                    [2] = {
                        effect = 2,
                        hp = -1511,
                        rage = 0,
                        toPos = 8
                    },
                    [3] = {
                        effect = 2,
                        hp = -1325,
                        rage = 0,
                        toPos = 9
                    }
                },
                dead = {
                },
                fromPos = 1,
                rage = -100,
                skillId = 1,
                type = 7
            }
        },
        [15] = {
            [1] = {
                affect = {
                    [1] = {
                        effect = 4,
                        hp = -362,
                        rage = 0,
                        toPos = 8
                    }
                },
                dead = {
                },
                fromPos = 2,
                rage = 50,
                skillId = 1001060,
                type = 7
            }
        },
        [16] = {
            [1] = {
                time = 0.3,
                type = 6
            }
        },
        [17] = {
            [1] = {
                chatType = 1,
                content_default = "賊人兇狠！我們趕緊撤退，通知掌教師兄！",
                content_female = "",
                posId = 8,
                sound_default = "10701.mp3",
                sound_female = "",
				sound_tw = "10701_tw.mp3",
				sound_n_tw = "",
                type = 4
            }
        },
        [18] = {
            [1] = {
                time = 0.2,
                type = 6
            }
        },
        [19] = {
            [1] = {
                outType = 2,
                posId = 8,
                type = 3
            },
            [2] = {
                outType = 2,
                posId = 7,
                type = 3
            },
            [3] = {
                outType = 2,
                posId = 9,
                type = 3
            }
        },
        [20] = {
            [1] = {
                time = 0.2,
                type = 6
            }
        },
        [21] = {
            [1] = {
                messageId = 10014,
                type = 17
            }
        },
        [22] = {
        },
        [23] = {
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
            cHP = 1600,
            cRP = 75,
            figureName = "hero_honglingbo",
            heroId = 0,
            mHP = 1600,
            name = "洪淩波",
            normalId = {
                [1] = 1001060
            },
            quality = 10,
            scale = 1,
            skillId = {
                [1] = 1002060
            },
            type = 0
        },
        [7] = {
            cHP = 3600,
            cRP = 75,
            figureName = "hero_zhangcuishan",
            heroId = 0,
            mHP = 3600,
            name = "掌教弟子",
            normalId = {
                [1] = 1001020
            },
            quality = 13,
            scale = 1,
            skillId = {
                [1] = 1002030
            },
            type = 0
        },
        [8] = {
            cHP = 1500,
            cRP = 75,
            figureName = "hero_yinliting",
            heroId = 0,
            mHP = 1500,
            name = "巡山弟子",
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
            cHP = 2000,
            cRP = 75,
            figureName = "hero_songqingshu",
            heroId = 0,
            mHP = 2000,
            name = "全真護教",
            normalId = {
                [1] = 1001023
            },
            quality = 10,
            scale = 1,
            skillId = {
                [1] = 1002023
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