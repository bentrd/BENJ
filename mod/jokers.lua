local jokers = {}
jokers[#jokers + 1] = {
    object_type = "Joker",
    name = "Ripened Dish",
    key = "ripened_dish",
    config = { extra = { Xmult = 1.75, odds = 2000 } },
    pos = { x = 0, y = 0 },
    loc_txt = {
        name = 'Ripened Dish',
        text = {
            "{C:attention}Each{} other joker",
            "gives {X:mult,C:white} X#1# {} Mult",
            "{C:green}#2# in #3#{} chance {C:attention}all{}",
            "jokers are destroyed"
        }
    },
    rarity = 2,
    cost = 8,
    discovered = true,
    blueprint_compat = true,
    atlas = "ripened_dish",
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.Xmult, '' .. (G.GAME and G.GAME.probabilities.normal or 1), center.ability.extra.odds } }
    end,
    yes_pool_flag = 'cavendish_extinct',
    calculate = function(self, card, context)
        if not context.individual and not context.repetition and not context.blueprint then
            if context.end_of_round then
                if pseudorandom('ripened_dish') < G.GAME.probabilities.normal / card.ability.extra.odds then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            play_sound('tarot1')
                            card.T.r = -0.2
                            card:juice_up(0.3, 0.4)
                            card.states.drag.is = true
                            card.children.center.pinch.x = true
                            G.E_MANAGER:add_event(Event({
                                trigger = 'after',
                                delay = 0.3,
                                blockable = false,
                                func = function()
                                    remove_all(G.jokers.cards)
                                    return true;
                                end
                            }))
                            return true
                        end
                    }))
                    return {
                        message = localize('k_extinct_ex')
                    }
                else
                    return {
                        message = localize('k_safe_ex')
                    }
                end
            elseif context.other_joker and context.other_joker.config.center.set == 'Joker' and card ~= context.other_joker then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        context.other_joker:juice_up(0.5, 0.5)
                        return true
                    end
                }))
                return {
                    message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult } },
                    Xmult_mod = card.ability.extra.Xmult,
                }
            end
        end
    end
}
jokers[#jokers + 1] = {
    object_type = "Atlas",
    key = "ripened_dish",
    path = "j_ripened_dish.png",
    px = 71,
    py = 95
}

jokers[#jokers + 1] = {
    object_type = "Joker",
    name = "Ripple Joker",
    key = "ripple_joker",
    config = {
        extra = {
            played_cards_goal = 30,
            played_cards_remaining = 30,
            retriggers = 0,
            increment = 1
        }
    },
    pos = { x = 0, y = 0 },
    loc_txt = {
        name = 'Ripple Joker',
        text = {
            "Retrigger {C:attention}each{} played",
            "card for every {C:attention}#1# {C:inactive}[#2#]",
            "cards played",
            "{C:inactive}(Currently {C:mult}#3#{C:inactive} ripples)"
        }
    },
    rarity = 3,
    cost = 12,
    discovered = true,
    blueprint_compat = true,
    atlas = "ripple_joker",
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.played_cards_goal, center.ability.extra.played_cards_remaining, center.ability.extra.retriggers } }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            for i = 1, #G.play.cards do
                if context.other_card == context.scoring_hand[i] then
                    return {
                        message = localize('k_again_ex'),
                        repetitions = card.ability.extra.retriggers,
                        card = card
                    }
                end
            end
        end
        if context.cardarea == G.jokers and context.after and not context.blueprint then
            if card.ability.extra.played_cards_remaining - #context.full_hand <= 0 then
                card.ability.extra.played_cards_remaining = card.ability.extra.played_cards_goal
                card.ability.extra.retriggers = card.ability.extra.retriggers + card.ability.extra.increment
                return {
                    message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra.increment } },
                    colour = G.C.MULT
                }
            else
                card.ability.extra.played_cards_remaining = card.ability.extra.played_cards_remaining -
                    #context.full_hand
            end
            return
        end
    end
}
jokers[#jokers + 1] = {
    object_type = "Atlas",
    key = "ripple_joker",
    path = "j_ripple_joker.png",
    px = 71,
    py = 95
}

jokers[#jokers + 1] = {
    object_type = "Joker",
    name = "Stonks Joker",
    key = "stonks_joker",
    pos = { x = 0, y = 0 },
    loc_txt = {
        name = 'Stonks Joker',
        text = {
            "If {C:attention}first discard{} of round",
            "has only {C:attention}1{} card,",
            "destroy it and {C:attention}increment",
            "this joker's sell value",
            "by the card's value",
            "{C:inactive}(ex: {C:green}Queen{C:inactive} -> {C:money}$12{C:inactive})"
        }
    },
    rarity = 3,
    cost = 12,
    discovered = true,
    blueprint_compat = false,
    atlas = "stonks_joker",
    calculate = function(self, card, context)
        if context.first_hand_drawn and not context.blueprint then
            local eval = function() return G.GAME.current_round.discards_used == 0 and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
        end
        if context.discard and not context.blueprint and G.GAME.current_round.discards_used <= 0 and #context.full_hand == 1 then
            card.ability.extra_value = card.ability.extra_value + context.full_hand[1]:get_id()
            card:set_cost()
            return {
                message = localize('k_val_up'),
                colour = G.C.MONEY,
                remove = true,
                card = card
            }
        end
    end
}
jokers[#jokers + 1] = {
    object_type = "Atlas",
    key = "stonks_joker",
    path = "j_stonks_joker.png",
    px = 71,
    py = 95
}

jokers[#jokers + 1] = {
    object_type = "Joker",
    name = "Sassy",
    key = "sassy_joker",
    config = { extra = { Xmult_extra = 0.5, Xmult = 1 } },
    pos = { x = 0, y = 0 },
    loc_txt = {
        name = 'Sassy',
        text = {
            "When {C:attention}Blind{} is selected,",
            "create {C:attention}1 {C:green}Doobskin",
            "When a {C:green}Doobskin{} is consumed,",
            "Sassy gains {X:mult,C:white} X#1# {} Mult",
            "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)"
        }
    },
    rarity = 2,
    cost = 7,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    atlas = "sassy_joker",
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.Xmult_extra, center.ability.extra.Xmult } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not (context.blueprint_card or card).getting_sliced and #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit then
            local jokers_to_create = math.min(1, G.jokers.config.card_limit - (#G.jokers.cards + G.GAME.joker_buffer))
            G.GAME.joker_buffer = G.GAME.joker_buffer + jokers_to_create
            G.E_MANAGER:add_event(Event({
                func = function()
                    for i = 1, jokers_to_create do
                        local doob = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_benj_doobskin', nil)
                        doob:add_to_deck()
                        G.jokers:emplace(doob)
                        doob:start_materialize()
                        G.GAME.joker_buffer = 0
                    end
                    return true
                end
            }))
            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil,
                { message = "420!", colour = G.C.GREEN })
        end

        if context.doobskin_consumed and not context.blueprint then
            card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_extra
            card_eval_status_text(card, 'extra', nil, nil, nil,
                {
                    message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult } },
                    colour =
                        G.C.RED
                })
        end

        if context.cardarea == G.jokers and not context.repetition and not context.individual and not context.before and not context.after and card.ability.extra.Xmult > 1 then
            return {
                message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult } },
                Xmult_mod = card.ability.extra.Xmult,
            }
        end
    end
}
jokers[#jokers + 1] = {
    object_type = "Atlas",
    key = "sassy_joker",
    path = "j_sassy_joker.png",
    px = 71,
    py = 95
}

jokers[#jokers + 1] = {
    object_type = "Joker",
    name = "Doobskin",
    key = "doobskin",
    config = { extra = { cost = 3, odds = 2 } },
    pos = { x = 0, y = 0 },
    loc_txt = {
        name = 'Doobskin',
        text = {
            "{C:green}#2# in #3#{} chance",
            "to be consumed",
            "{C:inactive}(Costs {C:money}$#1#{C:inactive} per round)"
        }
    },
    rarity = 1,
    cost = 1,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    atlas = "doobskin",
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.cost, '' .. (G.GAME and G.GAME.probabilities.normal or 1), center.ability.extra.odds } }
    end,
    yes_pool_flag = 'doobskin',
    calculate = function(self, card, context)
        if context.end_of_round and not context.individual and not context.repetition and not context.blueprint then
            if pseudorandom(card.ability.name == "Doobskin" and 'doobskin' or 'sassy_joker') < G.GAME.probabilities.normal / self.config.extra.odds then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('tarot1')
                        card.T.r = -0.2
                        card:juice_up(0.3, 0.4)
                        card.states.drag.is = true
                        card.children.center.pinch.x = true
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.3,
                            blockable = false,
                            func = function()
                                for _, v in pairs(G.jokers.cards) do
                                    if v.ability.name == 'Sassy' then
                                        v:calculate_joker({ doobskin_consumed = true })
                                    end
                                end
                                G.jokers:remove_card(card)
                                card:remove()
                                card = nil
                                return true;
                            end
                        }))
                        return true
                    end
                }))
                return {
                    message = 'wadiyatalkinabeet?',
                    colour = G.C.GREEN
                }
            else
                ease_dollars(-card.ability.extra.cost)
                return {
                    message = localize("$") .. -card.ability.extra.cost,
                    dollars = -card.ability.extra.cost,
                    colour = G.C.MONEY
                }
            end
        end
    end
}
jokers[#jokers + 1] = {
    object_type = "Atlas",
    key = "doobskin",
    path = "j_doobskin.png",
    px = 71,
    py = 95
}

jokers[#jokers + 1] = {
    object_type = "Joker",
    name = "Visible Joker",
    key = "visible_joker",
    config = { extra = { total_rounds = 4, rounds = 0 } },
    pos = { x = 0, y = 0 },
    loc_txt = {
        name = 'Visible Joker',
        text = {
            "After {C:attention}#1#{} rounds,",
            "sell this card to",
            "Create a {C:dark_edition,E:1,S:1.1}negative{} copy",
            "of a Joker you own",
            "{C:inactive}(Currently {C:attention}#2#{C:inactive}/#1#)"
        }
    },
    rarity = 3,
    cost = 12,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    atlas = "visible_joker",
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.total_rounds, center.ability.extra.rounds } }
    end,
    calculate = function(self, card, context)
        if context.selling_self and (card.ability.extra.rounds >= card.ability.extra.total_rounds) and not context.blueprint then
            local eval = function(card) return (card.ability.extra.loyalty_remaining == 0) and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
            local jokers = {}
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] ~= card then
                    jokers[#jokers + 1] = G.jokers.cards[i]
                end
            end
            if #jokers > 0 then
                if #G.jokers.cards <= G.jokers.config.card_limit then
                    card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil,
                        { message = localize('k_duplicated_ex') })
                    local chosen_joker = pseudorandom_element(jokers, pseudoseed('invisible'))
                    local joker = copy_card(chosen_joker, nil, nil, nil,
                        chosen_joker.edition and chosen_joker.edition.negative)
                    joker:set_edition({ negative = true }, true)
                    if joker.config.extra and joker.config.extra.rounds then joker.config.extra.rounds = 0 end
                    joker:add_to_deck()
                    G.jokers:emplace(joker)
                else
                    card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil,
                        { message = localize('k_no_room_ex') })
                end
            else
                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil,
                    { message = localize('k_no_other_jokers') })
            end
        end

        if context.end_of_round and not context.individual and not context.repetition and not context.blueprint then
            card.ability.extra.rounds = card.ability.extra.rounds + 1
            if card.ability.extra.rounds == card.ability.extra.total_rounds then
                local eval = function(card) return not card.REMOVED end
                juice_card_until(card, eval, true)
            end
            return {
                message = (card.ability.extra.rounds < card.ability.extra.total_rounds) and
                    (card.ability.extra.rounds .. '/' .. card.ability.extra.total_rounds) or localize('k_active_ex'),
                colour = G.C.FILTER
            }
        end
    end
}
jokers[#jokers + 1] = {
    object_type = "Atlas",
    key = "visible_joker",

    path = "j_visible_joker.png",
    px = 71,
    py = 95
}

jokers[#jokers + 1] = {
    object_type = "Joker",
    name = "Bleeding Hedge",
    key = "bleeding_hedge",
    config = {
        extra = {
            money = 9,
            s = 's',
            rounds = 3
        }
    },
    pos = { x = 0, y = 0 },
    loc_txt = {
        name = 'Bleeding Hedge',
        text = {
            "Gives {C:money}$#1#{} every round",
            "for the next {C:attention}#2#{} round#3#",
            "{C:inactive}(after which it is destroyed)"
        }
    },
    rarity = 1,
    cost = 6,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    atlas = "bleeding_hedge",
    no_pool_flag = 'bleeding_hedge_bled_out',
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.money, center.ability.extra.rounds, center.ability.extra.s } }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.individual and not context.repetition then
            if not context.blueprint then
                card.ability.extra.rounds = card.ability.extra.rounds - 1
                if card.ability.extra.rounds < 2 then card.ability.extra.s = '' end
            end

            card:juice_up(0.5, 0.5)
            ease_dollars(card.ability.extra.money)

            if card.ability.extra.rounds <= 0 then
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = "Bled out!", colour = G.C.RED })
                G.GAME.pool_flags.bleeding_hedge_bled_out = true
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('tarot1')
                        card.T.r = -0.2
                        card:juice_up(0.3, 0.4)
                        card.states.drag.is = true
                        card.children.center.pinch.x = true
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.3,
                            blockable = false,
                            func = function()
                                G.jokers:remove_card(card)
                                card:remove()
                                card = nil
                                return true;
                            end
                        }))
                        return true
                    end
                }))
            end

            return {
                message = localize('$') .. card.ability.extra.money,
                dollars = card.ability.extra.money,
                colour = G.C.MONEY
            }
        end
    end
}
jokers[#jokers + 1] = {
    object_type = "Atlas",
    key = "bleeding_hedge",
    path = "j_bleeding_hedge.png",
    px = 71,
    py = 95
}

jokers[#jokers + 1] = {
    object_type = "Joker",
    name = "Tempered Glass",
    key = "tempered_glass",
    config = {
        extra = { retriggers = 1 }
    },
    pos = { x = 0, y = 0 },
    loc_txt = {
        name = 'Tempered Glass',
        text = {
            "Scoring {C:attention}Glass Cards{}",
            "are retriggered",
            "and cannot shatter"
        }
    },
    rarity = 3,
    cost = 12,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    atlas = "tempered_glass",
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            for i = 1, #G.play.cards do
                if context.other_card == context.scoring_hand[i] and context.other_card.ability.name == "Glass Card" then
                    return {
                        message = localize('k_again_ex'),
                        repetitions = card.ability.extra.retriggers,
                        card = card
                    }
                end
            end
        end
    end
}
jokers[#jokers + 1] = {
    object_type = "Atlas",
    key = "tempered_glass",
    path = "j_tempered_glass.png",
    px = 71,
    py = 95
}

jokers[#jokers + 1] = {
    object_type = "Joker",
    name = "Randomizer",
    key = "randomizer_joker",
    config = { extra = 0 },
    pos = { x = 0, y = 0 },
    loc_txt = {
        name = 'Randomizer Joker',
        text = {
            "Use this joker to",
            "randomly transform",
            "{C:attention}all{} cards in your hand",
            "{C:inactive}(once per ante)"
        }
    },
    rarity = 2,
    cost = 6,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    atlas = "randomizer_joker",
    calculate = function(self, card, context)
        local eval = function(card)
            return card.config.extra ~= G.GAME.round_resets.ante and
                (G.hand and #G.hand.cards > 0) and not G.RESET_JIGGLES
        end
        juice_card_until(card, eval, true)
        if context.use_joker and not context.blueprint then
            card.config.extra = G.GAME.round_resets.ante
            for i = 1, #G.hand.cards do
                local percent = 1.15 - (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        G.hand.cards[i]:flip(); play_sound('card1', percent); G.hand.cards[i]:juice_up(0.3, 0.3); return true
                    end
                }))
                delay(0.2)
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local card = G.hand.cards[i]
                        local _edition = poll_edition('randomizer_joker', nil, true, true)
                        local _enhancement = pseudorandom_element(
                            { G.P_CENTERS.m_bonus, G.P_CENTERS.m_mult, G.P_CENTERS.m_wild, G.P_CENTERS.m_glass, G
                                .P_CENTERS.m_steel, G.P_CENTERS.m_stone, G.P_CENTERS.m_gold, G.P_CENTERS.m_lucky },
                            pseudoseed('randomizer_joker'))
                        local _seal = pseudorandom_element({ 'Red', 'Blue', 'Gold', 'Purple' },
                            pseudoseed('randomizer_joker'))
                        local _rank = pseudorandom_element(
                            { '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A' },
                            pseudoseed('randomizer_joker'))
                        local _suit = pseudorandom_element({ 'S_', 'H_', 'D_', 'C_' }, pseudoseed('randomizer_joker'))
                        card:set_edition(
                            pseudorandom(pseudoseed('rdmzr_jomker')) > 0.85 and _edition or G.P_CENTERS.e_base, true)
                        card:set_ability(
                            pseudorandom(pseudoseed('rdmzr_joker')) > 0.8 and _enhancement or G.P_CENTERS.c_base, true)
                        card:set_seal(pseudorandom(pseudoseed('rdmzr_joker')) > 0.9 and _seal or nil)
                        card:set_base(G.P_CARDS[_suit .. _rank])
                        return true
                    end
                }))
                percent = 0.85 + (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        G.hand.cards[i]:flip(); play_sound('tarot2', percent, 0.6); G.hand.cards[i]:juice_up(0.3, 0.3); return true
                    end
                }))
            end
        end
    end
}
jokers[#jokers + 1] = {
    object_type = "Atlas",
    key = "randomizer_joker",
    path = "j_randomizer_joker.png",
    px = 71,
    py = 95
}

jokers[#jokers + 1] = {
    object_type = "Joker",
    name = "Investment Firm",
    key = "investment_firm",
    config = {
        extra = {
            rate = 25,
            invested = 0,
            total_invested = 0,
            threshold = 10,
            Xmult = 1,
            Xmult_extra = 0.25,
            flag = false
        }
    },
    pos = { x = 0, y = 0 },
    loc_txt = {
        name = 'Investment Firm',
        text = {
            'Once per round use this card to',
            'Invest {C:attention}#1#%{} of your money and',
            "gain {X:mult,C:white} X#2# {} Mult per {C:money}$#3#{} invested",
            "{C:inactive}(Currently {X:money,C:white} $#4# {C:inactive} -> {X:mult,C:white} X#5# {C:inactive})"
        }
    },
    rarity = 3,
    cost = 8,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    atlas = "investment_firm",
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.rate, center.ability.extra.Xmult_extra, center.ability.extra.threshold, center.ability.extra.total_invested, center.ability.extra.Xmult } }
    end,
    yes_pool_flag = 'bleeding_hedge_bled_out',
    calculate = function(self, card, context)
        if context.use_joker and not context.blueprint then
            card.ability.extra.flag = true
            local investment = math.floor(G.GAME.dollars * card.ability.extra.rate / 100)
            if investment <= 0 then return end
            G.jokers:unhighlight_all()
            ease_dollars(-investment)
            card_eval_status_text(card, 'extra', nil, nil, nil,
                {
                    message = localize('$') .. -investment,
                    dollars = -investment,
                    colour = G.C.MONEY
                })
            card.ability.extra.invested = card.ability.extra.invested + investment
            card.ability.extra.total_invested = card.ability.extra.total_invested + investment
            if card.ability.extra.invested >= card.ability.extra.threshold then
                card.ability.extra.invested = card.ability.extra.invested -
                    card.ability.extra.invested % card.ability.extra.threshold
                card.ability.extra.Xmult = 1 +
                    math.floor(card.ability.extra.total_invested / card.ability.extra.threshold) *
                    card.ability.extra.Xmult_extra
                card_eval_status_text(card, 'extra', nil, nil, nil,
                    {
                        message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult } },
                        colour = G.C.RED
                    })
            end
        end

        if context.end_of_round and not context.individual and not context.repetition and not context.blueprint then
            if card.ability.extra.flag then
                card.ability.extra.flag = false
                local eval = function(card) return not card.ability.extra.flag end
                juice_card_until(card, eval, true)
            end
        end

        if context.cardarea == G.jokers and not context.repetition and not context.individual and not context.before and not context.after and card.ability.extra.Xmult > 1 then
            return {
                message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult } },
                Xmult_mod = card.ability.extra.Xmult,
            }
        end
    end
}
jokers[#jokers + 1] = {
    object_type = "Atlas",
    key = "investment_firm",
    path = "j_investment_firm.png",
    px = 71,
    py = 95
}

jokers[#jokers + 1] = {
    object_type = "Joker",
    name = "Pancakes",
    key = "pancakes",
    config = { extra = { flipped = false, mult = 20, chips = 150 } },
    pos = { x = 0, y = 0 },
    loc_txt = {
        name = 'Pancakes',
        text = {
            " ",
            " ",
            "{s:0.7,C:inactive}This joker {s:0.7,C:attention}flips{s:0.7,C:inactive} every round{}",
        }
    },
    rarity = 2,
    cost = 5,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    atlas = "pancakes",
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = { key = 'flip', set = 'Other' }
        if center.ability.extra.flipped then
            info_queue[#info_queue + 1] = { key = 'pancakes_1', set = 'Other', vars = { center.ability.extra.chips } }
            return {
                main_start = {
                    { n = G.UIT.T, config = { text = '\n+' .. center.ability.extra.mult, colour = G.C.MULT, scale = 0.32 } },
                    { n = G.UIT.T, config = { text = '\n Mult', colour = G.C.UI.TEXT_DARK, scale = 0.32 } }
                }
            }
        else
            info_queue[#info_queue + 1] = { key = 'pancakes_2', set = 'Other', vars = { center.ability.extra.mult } }
            return {
                main_start = {
                    { n = G.UIT.T, config = { text = '\n+' .. center.ability.extra.chips, colour = G.C.CHIPS, scale = 0.32 } },
                    { n = G.UIT.T, config = { text = '\n Chips', colour = G.C.UI.TEXT_DARK, scale = 0.32 } }
                }
            }
        end
    end,
    calculate = function(self, card, context)
        card.children.back = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS['benj_pancakes_flip'],
            card.params.bypass_back or (card.playing_card and G.GAME[card.back].pos or G.P_CENTERS['b_red'].pos))
        card.children.back.states.hover = card.states.hover
        card.children.back.states.click = card.states.click
        card.children.back.states.drag = card.states.drag
        card.children.back.states.collide.can = false
        card.children.back:set_role({ major = card, role_type = 'Glued', draw_major = card })

        if context.end_of_round and not context.individual and not context.repetition and not context.blueprint then
            card.ability.extra.flipped = not card.ability.extra.flipped
            card:flip()
        end
        if context.cardarea == G.jokers and not context.repetition and not context.individual and not context.before and not context.after then
            if card.ability.extra.flipped then
                return {
                    message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } },
                    mult_mod = card.ability.extra.mult,
                    colour = G.C.MULT
                }
            else
                return {
                    message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra.chips } },
                    chip_mod = card.ability.extra.chips,
                    colour = G.C.CHIPS
                }
            end
        end
    end
}
jokers[#jokers + 1] = {
    object_type = "Atlas",
    key = "pancakes",
    path = "j_pancakes.png",
    px = 71,
    py = 95
}
jokers[#jokers + 1] = {
    object_type = "Atlas",
    key = "pancakes_flip",
    path = "j_pancakes_flipped.png",
    px = 71,
    py = 95
}


return {
    init = function(self)
        -- Badges
        local card_h_popupref = G.UIDEF.card_h_popup
        function G.UIDEF.card_h_popup(card)
            local retval = card_h_popupref(card)
            if not card.config.center or                                                                                                         -- no center
                (card.config.center.unlocked == false and not card.bypass_lock) or                                                               -- locked card
                card.debuff or                                                                                                                   -- debuffed card
                (not card.config.center.discovered and ((card.area ~= G.jokers and card.area ~= G.consumeables and card.area) or not card.area)) -- undiscovered card
            then
                return retval
            end

            if card.config.center.name == "Sassy" then
                retval.nodes[1].nodes[1].nodes[1].nodes[3].nodes[1].nodes[1].nodes[2].config.object:remove()
                retval.nodes[1].nodes[1].nodes[1].nodes[3].nodes[1] = create_badge('Sassquatch', HEX('b77c51'), nil, 1.2)
            end

            return retval
        end

        -- Dict
        function SMODS.current_mod.process_loc_text()
            G.localization.descriptions.Other['flip'] = {
                name = 'Flipping Card',
                text = {
                    'This card has a',
                    '{C:green,E:1,S:1.1}different ability',
                    'on its other side'
                }
            }
            G.localization.descriptions.Other['pancakes_1'] = {
                name = 'Other side:',
                text = {
                    '   {C:chips}+#1#{} Chips   '
                }
            }
            G.localization.descriptions.Other['pancakes_2'] = {
                name = 'Other side:',
                text = {
                    '    {C:mult}+#1#{} Mult    '
                }
            }
        end

        -- Buttons
        G.FUNCS.randomize_hand = function(e)
            e.config.ref_table:calculate_joker({ use_joker = true })
        end

        G.FUNCS.can_randomize_hand = function(e)
            if e.config.ref_table.config.extra ~= G.GAME.round_resets.ante and (G.hand and #G.hand.cards > 0) then
                e.config.colour = G.C.DARK_EDITION
                e.config.button = 'randomize_hand'
            else
                e.config.colour = G.C.UI.BACKGROUND_INACTIVE
                e.config.button = nil
            end
        end

        G.FUNCS.invest = function(e)
            e.config.ref_table:calculate_joker({ use_joker = true })
        end

        G.FUNCS.can_invest = function(e)
            if math.floor(G.GAME.dollars * e.config.ref_table.ability.extra.rate / 100) >= 1 and not e.config.ref_table.ability.extra.flag then
                e.config.colour = G.C.MONEY
                e.config.button = 'invest'
            else
                e.config.colour = G.C.UI.BACKGROUND_INACTIVE
                e.config.button = nil
            end
        end

        local use_and_sell_buttonsref = G.UIDEF.use_and_sell_buttons
        function G.UIDEF.use_and_sell_buttons(card)
            local retval = use_and_sell_buttonsref(card)
            if card.area and card.area.config.type == 'joker' and card.ability.set == 'Joker' then
                if card.ability.name == "Randomizer" then
                    local button = {
                        n = G.UIT.C,
                        config = { align = "cr" },
                        nodes = {
                            {
                                n = G.UIT.C,
                                config = { ref_table = card, align = "cr", maxw = 1.25, padding = 0.1, r = 0.08, minw = 1.25, minh = 0, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = false, button = 'randomize_hand', func = 'can_randomize_hand' },
                                nodes = {
                                    { n = G.UIT.B, config = { w = 0.1, h = 0.6 } },
                                    { n = G.UIT.T, config = { text = localize('b_use'), colour = G.C.UI.TEXT_LIGHT, scale = 0.55, shadow = true } }
                                }
                            }
                        }
                    }
                    retval.nodes[1].nodes[2].nodes = {}
                    table.insert(retval.nodes[1].nodes[2].nodes, button)
                    return retval
                end
                if card.ability.name == "Investment Firm" then
                    local button = {
                        n = G.UIT.C,
                        config = { align = "cr" },
                        nodes = {
                            {
                                n = G.UIT.C,
                                config = { ref_table = card, align = "cr", maxw = 1.25, padding = 0.1, r = 0.08, minw = 1.25, minh = 0, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = false, button = 'invest', func = 'can_invest' },
                                nodes = {
                                    { n = G.UIT.B, config = { w = 0.1, h = 0.6 } },
                                    { n = G.UIT.T, config = { text = 'INVEST', colour = G.C.UI.TEXT_LIGHT, scale = 0.55, shadow = true } }
                                }
                            }
                        }
                    }
                    retval.nodes[1].nodes[2].nodes = {}
                    table.insert(retval.nodes[1].nodes[2].nodes, button)
                    return retval
                end
            end
            return retval
        end
    end,
    items = jokers
}
