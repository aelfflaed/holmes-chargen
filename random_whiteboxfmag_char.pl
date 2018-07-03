#!/usr/bin/perl
#
# Random White Box Fantastic Medieval Adventure Game character generator.
#
# forked from dmaxwell/holmes-chargen Copyright 2016 Doug Maxwell <doug@unixlore.net>
# This version Copyright 2018 Beth Peters <aelfflaed@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see
# <http://www.gnu.org/licenses/>.
#
use strict;
use warnings;
use Tie::IxHash;

# Attribute bonuses
my $cha_bonuses = {
    # 'score' => [max hirelings]
    '3'  => ['Not more than 1'],
    '4'  => ['Not more than 1'],
    '5'  => ['Not more than 2'],
    '6'  => ['Not more than 2'],
    '7'  => ['Not more than 3'],
    '8'  => ['Not more than 3'],
    '9'  => ['Not more than 4'],
    '10' => ['Not more than 4'],
    '11' => ['Not more than 4'],
    '12' => ['Not more than 4'],
    '13' => ['Not more than 5'],
    '14' => ['Not more than 5'],
    '15' => ['Not more than 6'],
    '16' => ['Not more than 6'],
    '17' => ['Not more than 7'],
    '18' => ['Not more than 7'],
};

my $dex_bonuses = {
    # Missile bonus
    '3'  => '-1',
    '4'  => '-1',
    '5'  => '-1',
    '6'  => '-1',
    '7'  => '+0',
    '8'  => '+0',
    '9'  => '+0',
    '10' => '+0',
    '11' => '+0',
    '12' => '+0',
    '13' => '+0',
    '14' => '+0',
    '15' => '+1',
    '16' => '+1',
    '17' => '+1',
    '18' => '+1',
};

my $con_bonuses = {
    # HP adj. only
    '3'  => -1,
    '4'  => -1,
    '5'  => -1,
    '6'  => -1,
    '7'  => 0,
    '8'  => 0,
    '9'  => 0,
    '10' => 0,
    '11' => 0,
    '12' => 0,
    '13' => 0,
    '14' => 0,
    '15' => 1,
    '16' => 1,
    '17' => 1,
    '18' => 1,
};

my $printable_con = {
    # 'score' => [hit point]
    '3'  => ['-1'],
    '4'  => ['-1'],
    '5'  => ['-1'],
    '6'  => ['-1'],
    '7'  => ['+0'],
    '8'  => ['+0'],
    '9'  => ['+0'],
    '10' => ['+0'],
    '11' => ['+0'],
    '12' => ['+0'],
    '13' => ['+0'],
    '14' => ['+0'],
    '15' => ['+1'],
    '16' => ['+1'],
    '17' => ['+1'],
    '18' => ['+1'],
};

my $int_bonuses = {
    # Additional languages, % chance to know spell, min spells, max spells
    '3'  => ['None','100%',1,'All'],
    '4'  => ['None','100%',1,'All'],
    '5'  => ['None','100%',1,'All'],
    '6'  => ['None','100%',1,'All'],
    '7'  => ['None','100%',1,'All'],
    '8'  => ['None','100%',1,'All'],
    '9'  => ['None','100%',1,'All'],
    '10' => ['None','100%',1,'All'],
    '11' => ['+1','100%',1,'All'],
    '12' => ['+2','100%',1,'All'],
    '13' => ['+3','100%',1,'All'],
    '14' => ['+4','100%',1,'All'],
    '15' => ['+5','100%',1,'All'],
    '16' => ['+6','100%',1,'All'],
    '17' => ['+7','100%',1,'All'],
    '18' => ['+8','100%',1,'All'],
};

# Weapons
#
# Weapon => damage
my $missile_weapons = {
    'Hand Axe'       => '1d6',
#    'Composite Bow'  => '1d6',
    'Long Bow'       => '1d6',
    'Short Bow'      => '1d6-1',
    'Heavy Crossbow' => '1d6+1',
    'Light Crossbow' => '1d6-1',
#    'Dagger'         => '1d6',
    'Spear'          => '1d6',
    'Sling'          => '1d6',
    'None'           => '',
};

# Weapon => damage
my $melee_weapons = {
    'Battle Axe'       => '1d6+1',
    'Hand Axe'         => '1d6',
    'Club'             => '1d6',    
    'Dagger'           => '1d6-1',
    'Flail'            => '1d6',
    'Mace'             => '1d6',
    'Morningstar'      => '1d6',
    'Pole Arm'         => '1d6+1',
#    'Halberd'          => '1d6',
    'Spear'            => '1d6',
    'Staff'            => '1d6',
    'Long Sword'       => '1d6',
    'Short Sword'      => '1d6-1',
    'Two-handed Sword' => '1d6+1',
    'Warhammer'        => '1d6',
};

# Added equipment for missile weapons
my $ancillary_equipment = {
#    'Composite Bow'  => 'Quiver & 20 arrows',
    'Long Bow'       => 'Quiver & 20 arrows',
    'Short Bow'      => 'Quiver & 20 arrows',
    'Heavy Crossbow' => 'Case & 30 quarrels',
    'Light Crossbow' => 'Case & 30 quarrels',
    'Sling'          => 'Pouch & 20 stones',
};

# Equipment from http://www.necropraxis.com/2012/07/20/odd-equipment/,
# modified slightly
my $equipment = {
    'cleric' => {
        3 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 10' pole, wooden cross, 4 GP},
        4 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 50' of rope, wooden cross, belladona - bunch, 4 GP},
        5 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 10' pole, wooden cross, 5 GP},
        6 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 50' of rope, 12 iron spikes, wooden cross, 3 stakes & mallet, steel mirror, 11 GP},
        7 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 10' pole, wooden cross, 2 small sacks, 18 GP},
        8 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 50' of rope, wooden cross, 2 small sacks, holy water/vial, 8 GP},
        9 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 10' pole, wooden cross, 2 small sacks, 3 stakes & mallet, steel mirror, 10 GP},
        10 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 50' of rope, wooden cross, belladona - bunch, 10 GP},
        11 => q{leather back pack, large sack, water/wine skin, lantern, 4 flasks oil, 1 week iron rations, 10' pole, wooden cross, small sack, 2 GP},
        12 => q{leather back pack, large sack, water/wine skin, lantern, 4 flasks oil, 1 week iron rations, 50' of rope, silver cross, holy water/vial, 4 GP},
        13 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 10'  pole, wooden cross, belladona - bunch, 4 GP},
        14 => q{leather back pack, large sack, water/wine skin, lantern, 4 flasks oil, 1 week iron rations, 50' of rope, silver cross, wolvesbane - bunch, 10 GP},
        15 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 10' pole, wooden cross, 2 flasks oil, wolvesbane - bunch, 1 GP},
        16 => q{leather back pack, large sack, water/wine skin, lantern, 4 flasks oil, 1 week iron rations, 50' of rope, silver cross, belladona - bunch, 3 stakes & mallet, steel mirror, wolvesbane - bunch, 12 GP},
        17 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 10' pole, wooden cross, holy water/vial, belladona - bunch, wolvesbane - bunch, 20 GP},
        18 => q{leather back pack, large sack, water/wine skin, lantern, 4 flasks oil, 1 week iron rations, 50' of rope, silver cross, holy water/vial, 12 iron spikes, belladona - bunch, 3 stakes & mallet, small sack, 10 GP},
    },

    'fighter' => {
        3 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 50' of rope, 3 GP},
        4 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 10' pole, 1 GP},
        5 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 50' of rope, 3 GP},
        6 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 10' pole, 7 GP},
        7 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 50' of rope, 12 iron spikes, 11 GP},
        8 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 10' pole, 4 GP},
        9 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 50' of rope, 12 iron spikes, 11 GP},
        10 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 10' pole, 4 GP},
        11 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 50' of rope, 2 flasks oil, 12 iron spikes, 9 GP},
        12 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 10' pole, 12 iron spikes, 2 GP},
        13 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 50' of rope, small sack, 12 iron spikes, 10 GP},
        14 => q{leather back pack, large sack, water/wine skin, lantern, 4 flasks oil, 1 week iron rations, 10' pole, 12 iron spikes, 5 GP},
        15 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 50' of rope, 5 flasks oil, 15 GP},
        16 => q{leather back pack, large sack, water/wine skin, lantern, 4 flasks oil, 1 week iron rations, 10' pole, 2 small sacks, 15 GP},
        17 => q{leather back pack, large sack, water/wine skin, lantern, 4 flasks oil, 1 week iron rations, 50' of rope, 12 iron spikes, 10 GP},
        18 => q{leather back pack, large sack, water/wine skin, lantern, 4 flasks oil, 1 week iron rations, 10' pole, 12 iron spikes, 9 GP},
    },

    'thief' => {
        3 => q{6 torches, leather back pack, 2 large sacks, water/wine skin, 1 week iron rations, 50' of rope, 3 GP},
        4 => q{6 torches, leather back pack, 2 large sacks, water/wine skin, 1 week iron rations, 10' pole, 1 GP},
        5 => q{6 torches, leather back pack, 2 large sacks, water/wine skin, 1 week iron rations, 50' of rope, 3 GP},
        6 => q{6 torches, leather back pack, 2 large sacks, water/wine skin, 1 week iron rations, 10' pole, 7 GP},
        7 => q{6 torches, leather back pack, 2 large sacks, water/wine skin, 1 week iron rations, 50' of rope, 12 iron spikes, 11 GP},
        8 => q{6 torches, leather back pack, 2 large sacks, water/wine skin, 1 week iron rations, 10' pole, 4 GP},
        9 => q{6 torches, leather back pack, 2 large sacks, water/wine skin, 1 week iron rations, 50' of rope, 12 iron spikes, 11 GP},
        10 => q{6 torches, leather back pack, 2 large sacks, water/wine skin, 1 week iron rations, 10' pole, 4 GP},
        11 => q{6 torches, leather back pack, 2 large sacks, water/wine skin, 1 week iron rations, 50' of rope, 2 flasks oil, 12 iron spikes, 9 GP},
        12 => q{6 torches, leather back pack, 2 large sacks, water/wine skin, 1 week iron rations, 10' pole, 12 iron spikes, 2 GP},
        13 => q{6 torches, leather back pack, 2 large sacks, water/wine skin, 1 week iron rations, 50' of rope, small sack, 12 iron spikes, 10 GP},
        14 => q{lantern, leather back pack, 2 large sacks, water/wine skin, lantern, 4 flasks oil, 1 week iron rations, 10' pole, 12 iron spikes, 5 GP},
        15 => q{lantern, leather back pack, large sack, water/wine skin, 1 week iron rations, 50' of rope, 5 flasks oil, 15 GP},
        16 => q{lantern, leather back pack, large sack, water/wine skin, lantern, 4 flasks oil, 1 week iron rations, 10' pole, 2 small sacks, 15 GP},
        17 => q{lantern, leather back pack, large sack, water/wine skin, lantern, 4 flasks oil, 1 week iron rations, 50' of rope, 2 small sacks, 12 iron spikes, 10 GP},
        18 => q{lantern, leather back pack, large sack, water/wine skin, lantern, 4 flasks oil, 1 week iron rations, 10' pole, 2 small sacks, 12 iron spikes, 9 GP},
    },


    'fighter/magic user' => {
        3 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 50' of rope, 3 GP},
        4 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 10' pole, 1 GP},
        5 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 50' of rope, 3 GP},
        6 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 10' pole, 7 GP},
        7 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 50' of rope, 12 iron spikes, 11 GP},
        8 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 10' pole, 4 GP},
        9 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 50' of rope, 12 iron spikes, 11 GP},
        10 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 10' pole, 4 GP},
        11 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 50' of rope, 2 flasks oil, 12 iron spikes, 9 GP},
        12 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 10' pole, 12 iron spikes, 2 GP},
        13 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 50' of rope, small sack, 12 iron spikes, 10 GP},
        14 => q{leather back pack, large sack, water/wine skin, lantern, 4 flasks oil, 1 week iron rations, 10' pole, 12 iron spikes, 5 GP},
        15 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 50' of rope, 5 flasks oil, 15 GP},
        16 => q{leather back pack, large sack, water/wine skin, lantern, 4 flasks oil, 1 week iron rations, 10' pole, 2 small sacks, 15 GP},
        17 => q{leather back pack, large sack, water/wine skin, lantern, 4 flasks oil, 1 week iron rations, 50' of rope, 12 iron spikes, 10 GP},
        18 => q{leather back pack, large sack, water/wine skin, lantern, 4 flasks oil, 1 week iron rations, 10' pole, 12 iron spikes, 9 GP},
    },

    'magic user' => {
        3 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 10' pole, 44 GP},
        4 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 2 flasks oil, 50' of rope, 73 GP},
        5 => q{leather back pack, large sack, water/wine skin, lantern, 4 flasks oil, 1 week iron rations, 10' pole, 71 GP},
        6 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 50' of rope, vial of holy water, 39 GP},
        7 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 10' pole 5 flasks of oil, silver mirror, belladona - bunch, 29 GP},
        8 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 50' of rope, 2 holy water/vials, 34 GP},
        9 => q{leather back pack, large sack, water/wine skin, lantern, 4 flasks oil, 1 week iron rations, 10' pole, vial of holy water, 16 GP},
        10 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 50' of rope, 2 holy water/vials, 24 GP},
        11 => q{leather back pack, large sack, water/wine skin, lantern, 4 flasks oil, 1 week iron rations, 10' pole, 67 GP},
        12 => q{leather back pack, large sack, water/wine skin, lantern, 4 flasks oil, 1 week iron rations, 50' of rope, 77 GP},
        13 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 10' pole, 47 GP},
        14 => q{6 torches, leather back pack, large sack, water/wine skin, 1 week iron rations, 50' of rope, 21 GP},
        15 => q{leather back pack, large sack, water/wine skin, lantern, 4 flasks oil, 1 week iron rations, 10' pole, 17 GP},
        16 => q{leather back pack, large sack, water/wine skin, lantern, 4 flasks oil, 1 week iron rations, 50' of rope, 57 GP},
        17 => q{leather back pack, large sack, water/wine skin, lantern, 4 flasks oil, 1 week iron rations, 10' pole, 27 GP},
        18 => q{leather back pack, large sack, water/wine skin, lantern, 4 flasks oil, 1 week iron rations, 50' of rope, 37 GP},
    },
};

my $turn_undead = {
    'cleric' => {
        '1' => [10,13,15,17,'-','-','-','-'],
        '2' => [7,10,13,15,17,'-','-','-'],
        '3' => [4,7,10,13,15,17,'-','-'],
    },
};

# Class data to level 3 as per WB:FMAG
# Elves are an issue since they can be FM/MU levels 1/1, 2/1, 2/2,
# 3/2, 3/3 so right now we just spit out level 1 characters. 

my $classes = {
    'magic user' => {
        'armor'   => ['none'],
        'weapons' => ['Dagger','Staff'],
        'level' => {
            # [min-xp,max-xp,HD,sav,l1,l2,l3,l4,l5,l6,title]
            '1'  => [0,2499,'1d6',[15,13,15,15,13],1,0,0,0,0,0,''],
            '2'  => [2500,4999,'1d6+1',[14,12,14,14,12],2,0,0,0,0,0,''],
            '3'  => [5000,9999,'2d6',[13,11,13,13,11],3,1,0,0,0,0,''],
        },
        'spells' => {
            '1' => ['Charm Person','Detect Magic','Hold Portal','Light','Protection from Chaos','Read Languages','Read Magic','Sleep'],
            '2' => ['Detect Chaos','Detect Invisiblity','Detect Thoughts (ESP)','Invisibility','Knock','Levitate','Light, Continual','Locate Object','Phantasmal Force','Web','Wizard Lock'],
        },
        'xp_bonus' => {
            'int' => {
                3  => 0,
                4  => 0,
                5  => 0,
                6  => 0,
                7  => 0,
                8  => 0,
                9  => 0,
                10 => 0,
                11 => 0,
                12 => 0,
                13 => 5,
                14 => 5,
                15 => 5,
                16 => 5,
                17 => 5,
                18 => 5,
            },
        },
    },
    'cleric' => {
        'armor'   => ['any'],
        'weapons' => ['Club','Flail','Mace','Morningstar','Staff'],
        'level' => {
            # [min-xp,max-xp,HD,sav,bhb,l1,l2,l3,l4,l5,title]
            '1'  => [0,1499,'1d6',[13,15,13,15,15],0,0,0,0,0,''],
            '2'  => [1500,2999,'2d6',[12,14,12,14,14],1,0,0,0,0,''],
            '3'  => [3000,5999,'3d6',[11,13,11,13,13],2,0,0,0,0,''],
        },
        'spells' => {
            '1' => ['Cure Light Wounds','Detect Chaos','Detect Magic','Light','Protection from Chaos','Purify Food and Water'],
            '2' => ['Bless','Find Traps','Know Alignment','Hold Person','Speak with Animals'],
        },
        'xp_bonus' => {
            'wis' => {
                3  => 0,
                4  => 0,
                5  => 0,
                6  => 0,
                7  => 0,
                8  => 0,
                9  => 0,
                10 => 0,
                11 => 0,
                12 => 0,
                13 => 0,
                14 => 0,
                15 => 5,
                16 => 5,
                17 => 5,
                18 => 5,
            },
        },
    },
    'fighter' => {
        'armor'   => ['any'],
        'weapons' => ['any'],
        'level'   => {
            # [min-xp,max-xp,HD,sav,title]
            '1'  => [0,1999,'1d6+1',[12,14,14,14,14],''],
            '2'  => [2000,3999,'2d6',[11,13,13,13,13],''],
            '3'  => [4000,7999,'3d6',[10,12,12,12,12],''],
        },
        xp_bonus => {
            'str' => {
                3  => 0,
                4  => 0,
                5  => 0,
                6  => 0,
                7  => 0,
                8  => 0,
                9  => 0,
                10 => 0,
                11 => 0,
                12 => 0,
                13 => 0,
                14 => 0,
                15 => 5,
                16 => 5,
                17 => 5,
                18 => 5,
            },
        },
    },
    # Note we are allowing halfling thieves, using Greyhawk racial skill bonuses
    'thief' => {
        'armor'   => ['leather'],
        'weapons' => ['any'],
        'level'   => {
            # [min-xp,max-xp,HD,sav,skills,halfling skills,title]
            '1'  => [0,1199,'1d6',[14,14,14,14,14],   [2],[2],''],
            '2'  => [1200,2399,'2d6',[11,13,13,13,13],[2],[2],''],
            '3'  => [2400,-1,'3d6',[10,12,12,12,12],  [2],[2],''],
        },
        xp_bonus => {
            'dex' => {
                3  => 0,
                4  => 0,
                5  => 0,
                6  => 0,
                7  => 0,
                8  => 0,
                9  => 0,
                10 => 0,
                11 => 0,
                12 => 0,
                13 => 0,
                14 => 0,
                15 => 5,
                16 => 5,
                17 => 5,
                18 => 5,
            },
        },
    },
    'fighter/magic user' => {
        'armor'   => ['any'],
        'weapons' => ['any'],
        'level'   => {
            # [min-xp,max-xp,HD,sav,title]
            '1'  => [0,1999,'1d6',[15,13,12,13,15],'veteran/Medium'],
            '2'  => [2000,3999,'2d6',[15,13,12,13,15],'warrior/Seer'],
            '3'  => [4000,7999,'3d6',[15,13,12,13,15],'swordsman/Conjurer'],
        },
        'spells' => {
            '1' => ['Protection from Evil','Read Languages','Read Magic','Shield','Sleep',"Tenser's Floating Disc",'Ventriloquism','Detect Magic','Enlargements','Hold Portal','Light','Magic Missile','Charm Person','Dancing Lights'],
            '2' => ['Audible Glamer','Continual Light','Darkness','Detect Evil','Detect Invisible','Locate Object','Magic Mouth','ESP','Mirror Image','Phantasmal Forces','Pyrotechnics','Ray of Enfeeblement','Invisibility','Knock','Strength','Web','Levitate','Wizard Lock'],
        },
        xp_bonus => {
            'str' => {
                3  => -20,
                4  => -20,
                5  => -20,
                6  => -20,
                7  => -10,
                8  => -10,
                9  => 0,
                10 => 0,
                11 => 0,
                12 => 0,
                13 => 5,
                14 => 5,
                15 => 10,
                16 => 10,
                17 => 10,
                18 => 10,
            },
            'int' => {
                3  => -20,
                4  => -20,
                5  => -20,
                6  => -20,
                7  => -10,
                8  => -10,
                9  => 0,
                10 => 0,
                11 => 0,
                12 => 0,
                13 => 5,
                14 => 5,
                15 => 10,
                16 => 10,
                17 => 10,
                18 => 10,
            },
        },
    },
};

my $armor = {
    'leather'         => 2,
    'chain mail'      => 4,
    'plate mail'      => 6,
    'shield'          => 1,
    'none'            => 0,
};

my $base_ac      = 9;
my $max_xp_bonus = 10;
my $max_xp_penalty = -20;

my %race_abilities = (
    'halfling' => q{
Out-of-doors Halflings are difficult to see, having the ability to
vanish into woods or undergrowth. They are like dwarves in their
resistance to magic. Halflings are extremely accurate with missiles
and fire any missile at + 1.
},
    'elf'      => q{
Elves can use all the weapons and armor of the fighter, including
all magical weapons, and can also cast spells like a magic-user. They
can detect secret hidden doors about one-third of the time. They have
infravision; like dwarves, they can see 60 feet in the dark.  They are
not paralyzed by the touch of ghouls. Elves can speak the languages of
orcs, hobgoblins and gnolls as well as Elvish and the Common speech.
},
    'dwarf'    => q{
Dwarves are sturdy fighters and are especially resistant to magic as
shown by their better saving throws against magical attack. They have
infravision and can see 60 feet in the dark. Underground, they can
detect slanting passages, traps, shifting wails and new construction
about one-third of the time. They are the only ones who can wield the
+3 Magic War Hammer. Dwarves can all speak the languages of gnomes,
kobolds and goblins.
},
    'human'    => q{},
);

# Helper subs for die rolls
sub roll_1d2 {

    return int( rand(2) ) + 1;

}

sub roll_1d3 {

    return int( rand(3) ) + 1;

}

sub roll_1d4 {

    return int( rand(4) ) + 1;

}

sub roll_1d8 {

    return int( rand(8) ) + 1;

}

sub roll_1d10 {

    return int( rand(10) ) + 1;

}

sub roll_1d6 {

    return int( rand(6) ) + 1;

}

sub roll_2d6 {

    return roll_1d6() + roll_1d6();

}

sub roll_3d6 {

    return roll_1d6() + roll_1d6() + roll_1d6();

}

sub roll_nd4 {
    my $n = shift;

    $n = ( $n < 0 || !$n ) ? 1 : $n;
    my $res = 0;

    foreach (1..$n) {
        $res += roll_1d4();
    }

    return $res;
}

sub roll_nd6 {
    my $n = shift;

    $n = ( $n < 0 || !$n ) ? 1 : $n;
    my $res = 0;

    foreach (1..$n) {
        $res += roll_1d6();
    }

    return $res;
}

sub roll_nd8 {
    my $n = shift;

    $n = ( $n < 0 || !$n ) ? 1 : $n;
    my $res = 0;

    foreach (1..$n) {
        $res += roll_1d8();
    }

    return $res;
}

sub gen_age {

    my $args  = shift;
    my $race  = $$args{race}  || 'human';
    my $level = $$args{level} || 1;
    my $ages  = {
        dwarf    => [56,114,5],
        halfling => [33,54,3],
        elf      => [180,454,20],
        human    => [20,38,2],
    };
    my $start_age   = $$ages{$race}->[0];
    my $end_age     = $$ages{$race}->[1];
    my $level_fudge = $level * $$ages{$race}->[2];

    return (int(rand($end_age-$start_age+1))+$start_age)+$level_fudge;

};

sub sum_array {

    my $sum = 0;

    foreach ( @_ ) {
        $sum += $_;
    }

    return $sum;

}

sub attribute_roll {

    my $num_d6 = shift;

    return roll_3d6() if $num_d6 <= 3;

    my @sorted = sort { $b <=> $a }
                 map { roll_1d6() }
                 (1..$num_d6);

    return sum_array(@sorted[0..2]);
}

# Generation subs for random character attributes
sub gen_race {

    my $races = ['dwarf','elf','halfling','human'];
    return $races->[roll_1d4()-1];
}

sub gen_class {
    my $args = shift;

    my $smart_class = $$args{smart_class} || 0;
    my $str = $$args{str};
    my $int = $$args{int};
    my $wis = $$args{wis};
    my $dex = $$args{dex};
    my $classes = ['fighter','thief','magic user','cleric'];
    my $race = $$args{race} || gen_race();

    # $smart_class allows us to tweak the class choice logically based
    # on higher prime requisite attributes
    if ( $smart_class && $race eq 'human' ) {
        return 'fighter' if $str >= 15;
        return 'cleric' if $wis >= 15;
        return 'magic user' if $wis >= 15;
        return 'thief' if $dex >= 15;
    }

    return $classes->[roll_1d4()-1] if ( $race eq 'human' );
    return 'fighter/magic user' if ( $race eq 'elf' );
    return $classes->[roll_1d2()-1] if ( $race eq 'halfling' );
    return 'fighter';
}

sub gen_weapon {
    my $args            = shift;

    my $class           = $$args{class};
    my $race            = $$args{race};
    my $type            = $$args{type} || 'melee';
    my @melee_weapons   = keys %$melee_weapons;
    my @missile_weapons = keys %$missile_weapons;

    my $allowed_weapons = {
        'melee' => {
            'magic user' => ['Dagger'],
            'cleric' => ['Flail','Mace','Morningstar'],
            'fighter' => \@melee_weapons,
            'thief' => ['Dagger','Sword','Hand Axe'],
            'fighter/magic user' => \@melee_weapons,
        },
        'missile' => {
            'magic user' => ['Dagger'],
            'cleric' => ['None'],
            'fighter' => \@missile_weapons,
            'thief' => \@missile_weapons,
            'fighter/magic user' => \@missile_weapons,
       },
    };

    my $rand = {
        'melee' => {
            'magic user' => 1,
            'cleric' => 3,
            'fighter' => scalar(@melee_weapons),
            'thief' => 3,
            'fighter/magic user' => scalar(@melee_weapons),
        },
        'missile' => {
            'magic user' => 2,
            'cleric' => 1,
            'fighter' => scalar(@missile_weapons),
            'thief' => scalar(@missile_weapons),
            'fighter/magic user' => scalar(@missile_weapons),
        },
    };

    my $weapon = $$allowed_weapons{$type}{$class}->[ int(rand($$rand{$type}{$class})) - 1 ];

    if ( $race eq 'halfling' || $race eq 'dwarf' ) {
        $weapon = 'Sword' if ( $weapon eq 'Two-handed Sword' || $weapon eq 'Pole Arm' || $weapon eq 'Halberd' );
        $weapon = 'Short Bow' if ( $weapon eq 'Long Bow' || $weapon eq 'Composite Bow' );
    }

    return $weapon;
}

sub gen_damage {
    my $args = shift;

    my $weapon = $$args{weapon};
    my $type = $$args{type};

    return '' if (!$weapon || $weapon eq 'None');
    return ( $type eq 'missile' && $weapon ) ? $$missile_weapons{$weapon} : $$melee_weapons{$weapon};
}

sub gen_armor {
    my $args = shift;

    my $class = $$args{class};
    my $level = $$args{level} || 1;

    my $new_armor = ['leather','leather','chain mail','chain mail','chain mail','plate mail'];

    return 'none' if ( $class eq 'magic user' );
    return 'leather' if ( $class eq 'thief' );

    if ( $level <= 1 ) {
        return $new_armor->[roll_1d6()-1];
    } else {
        return 'plate mail';
    }
}

sub gen_shield {
    my $args = shift;

    my $class = $$args{class};
    my $shield = ['shield','none'];

    return 'none' if ( $class eq 'magic user' || $class eq 'thief' );
    return $shield->[roll_1d2()-1];
}

sub gen_helmet {
    my $args = shift;

    my $class = $$args{class};
    my $helmet = ['helmet','none'];

    return 'none' if ( $class eq 'magic user' || $class eq 'thief' );
    return $helmet->[roll_1d2()-1];
}

sub gen_align {
    my $align = ['Neutral','Lawful Good','Chaotic Good'];

    return $align->[roll_1d3()-1];
}

sub gen_gender {
    my $align = ['Male','Female'];

    return $align->[roll_1d2()-1];
}

sub gen_deity {
    my $args = shift;

    my $class = $$args{class};
    return ( $class eq 'cleric' ) ? 'Crom' : 'None';
}

sub gen_spells {
    my $args = shift;

    my $class = $$args{class};
    my $race = $$args{race};
    my $level = $$args{level};
    $level = 1 if ($level < 1);
    $level = 3 if ($level > 3);
    my $l1_mu_spells = ['Charm Person','Hold Portal','Light','Magic Missile','Protection from Evil','Shield','Sleep','Ventriloquism'];
    return $l1_mu_spells->[roll_1d8()-1] if ( $level == 1 && ($class eq 'magic user' || $race eq 'elf') );
    return 'None' if ( $race ne 'elf' && (($level == 1 && $class eq 'cleric') || $class eq 'fighter' || $class eq 'thief' ));

    my $known_spells = {};
    my $level_stats = $$classes{$class}{'level'}{$level};
    my $last_index = scalar(@$level_stats) - 1;
    my @spells_per_level = @$level_stats[5..$last_index];
    my $current_level = 1;
    foreach my $num_spells ( @spells_per_level ) {
        my $total_spells = scalar(@{$$classes{$class}{'spells'}{$current_level}});
        foreach ( 1..$num_spells ) {
            push @{$$known_spells{$current_level}}, $$classes{$class}{spells}{$current_level}->[int(rand($total_spells))];
        }
        $current_level++;
    }
    return $known_spells;
}

sub gen_save {
    my $args = shift;

    my $class = $$args{class};
    my $level = $$args{level};
    my $race  = $$args{race};

    return [14,11,10,12,14] if ( $race eq 'dwarf' || $race eq 'halfling' );
    return $$classes{$class}{'level'}{$level}->[3];
}

sub gen_thief_skills {
    my $args = shift;

    my $class = $$args{class};
    my $level = $$args{level};
    my $race  = $$args{race};

    return $$classes{$class}{'level'}{$level}->[5] if $race eq 'halfling';
    return $$classes{$class}{'level'}{$level}->[4];
}

sub gen_xp_bonus {
    my $args = shift;

    my $class = $$args{class};
    my $level = $$args{level};
    my $str = $$args{str};
    my $int = $$args{int};
    my $wis = $$args{wis};
    my $bonus = 0;

    if ( $$classes{$class}{'xp_bonus'}{'str'} ) {
        $bonus += $$classes{$class}{'xp_bonus'}{'str'}{$str};
    }
    if ( $$classes{$class}{'xp_bonus'}{'int'} ) {
        $bonus += $$classes{$class}{'xp_bonus'}{'int'}{$int};
    }
    if ( $$classes{$class}{'xp_bonus'}{'wis'} ) {
        $bonus += $$classes{$class}{'xp_bonus'}{'wis'}{$wis};
    }
    return ( $bonus > $max_xp_bonus ) ? $max_xp_bonus : $bonus;
    return ( $bonus < $max_xp_penalty ) ? $max_xp_penalty : $bonus;
}

sub gen_ac {
    my $args       = shift;

    my $armor_worn = $$args{armor};
    my $shield     = $$args{shield};
    my $dex        = $$args{dex};
    my $use_dex_ac = $$args{use_dex_ac};

    my $ac  = $base_ac  - $$armor{$armor_worn} - $$armor{$shield} - (( $use_dex_ac ) ? $$dex_bonuses{$dex} : 0);
    return qq{$ac};
}

sub gen_hp {
    my $args  = shift;

    my $class = $$args{class};
    my $level = $$args{level};
    my $race  = $$args{race};
    my $con   = $$args{con};
    my $hd    = $$classes{$class}{'level'}{$level}->[2];
    my $hp    = 0;

    $hd =~ s/d8/d6/ if ( $race eq 'elf' || $race eq 'halfling' );
    $hd =~ s/d6/d4/ if ( $class eq 'thief' );

    if ( $hd =~ m{^(\d+)d(\d)p(\d)$} ) {
        if ( $2 == 4 ) {
            $hp = roll_nd4($1) + $$con_bonuses{$con};
        } elsif ( $2 == 6 ) {
            $hp = roll_nd6($1) + $$con_bonuses{$con};
        } elsif ( $2 == 8 ) {
            $hp = roll_nd8($1) + $$con_bonuses{$con};
        }
        $hp += $3;
    } elsif ( $hd =~ m{^(\d)d(\d+)$} ) {
        if ( $2 == 4 ) {
            $hp = roll_nd4($1) + $$con_bonuses{$con};
        } elsif ( $2 == 6 ) {
            $hp = roll_nd6($1) + $$con_bonuses{$con};
        } elsif ( $2 == 8 ) {
            $hp = roll_nd8($1) + $$con_bonuses{$con};
        }
    }

    return 1 if $hp < 1;
    return $hp;
}

sub gen_gp {
    my $args = shift;
    my $level = $$args{level};

    return ( $level == 1 ) ? roll_3d6() * 10 : roll_nd6(10 * $level) * ( int( rand(10) ) + 1 );
}

# Holmesian random names from
# http://zenopusarchives.blogspot.com/2013/06/holmesian-random-names.html
#
# Given an array ref, return a random array element
sub arnd {
    my $arrayref = shift;

    return $arrayref->[rand @{$arrayref}];
}

sub gen_name {

    my $syllable = ["A","Ael","Af","Ak","Al","Am","An","Ar","Baf","Bar","Bee","Bel","Ber","Berd","Bes",
                    "Bo","Bo","Bol","Bor","Bran","Brose","Bru","Bur","Car","Chor","Cig","Cla","Da","Da","Dan","Do","Do","Dock","Doh","Don","Dor",
                    "Dor","Dre","Drebb","E","Eg","Ek","El","El","End","Er","Er","Es","Eth","Eth","Ev","Fal","Fan","Far","Feg","Fen","Fi","Ful",
                    "Fum","Ga","Gahn","Gaith","Gar","Gar","Gen","Ger","Glen","Go","Go","Gram","Grink","Gulf","Ha","Hag","Hal","Han","Harg",
                    "Ho","Hol","Hor","I","Ig","In","Ith","Jax","Jo","Jur","Ka","Kan","Kra","Krac","Ky","La","Laf","Lag","Lap","Le","Lef","Lem","Lis",
                    "Lo","Lu","Mal","Mar","Me","Mer","Mez","Mez","Mich","Mil","Mis","Mo","Mo","Moo","Mul","Mun","Mun","Mur","Mus","Na","Na","Ned",
                    "Nes","Nick","No","Nor","Nos","Nu","O","Omes","Os","Pal","Pen","Phil","Po","Pos","Poy","Pres","Pus","Quas","Que","Ra","Rag",
                    "Ralt","Ram","Ray","Ree","Rem","Rin","Ris","Ro","Ro","Ron","Sa","Sa","See","Ser","Shal","Sho","Sho","Sil","Sit","Spor",
                    "Sun","Sur","Sus","Tar","Tar","Tas","Tee","Ten","Ten","Teth","To","To","Ton","Ton","Tra","Treb","Tred","Tue","U","Va","Vak","Ven",
                    "Ver","Wal","Web","Wil","Xor","Y","Yor","Ys","Zef","Zell","Zen","Zer","Zo","Zo","Zort"];

    my $syllable2 = [" A"," Ael"," Af"," Ak"," Al"," Am"," An"," Ar"," Baf"," Bar"," Bee"," Bel"," Ber"," Berd"," Bes",
                     " Bo"," Bo"," Bol"," Bor"," Bran"," Brose"," Bru"," Bur"," Car"," Chor"," Cig"," Cla"," Da"," Da"," Dan"," Do"," Do"," Dock"," Doh"," Don"," Dor",
                     " Dor"," Dre"," Drebb"," E"," Eg"," Ek"," El"," El"," End"," Er"," Er"," Es"," Eth"," Eth"," Ev"," Fal"," Fan"," Far"," Feg"," Fen"," Fi"," Ful",
                     " Fum"," Ga"," Gahn"," Gaith"," Gar"," Gar"," Gen"," Ger"," Glen"," Go"," Go"," Gram"," Grink"," Gulf"," Ha"," Hag"," Hal"," Han"," Harg",
                     " Ho"," Hol"," Hor"," I"," Ig"," In"," Ith"," Jax"," Jo"," Jur"," Ka"," Kan"," Kra"," Krac"," Ky"," La"," Laf"," Lag"," Lap"," Le"," Lef"," Lem"," Lis",
                     " Lo"," Lu"," Mal"," Mar"," Me"," Mer"," Mez"," Mez"," Mich"," Mil"," Mis"," Mo"," Mo"," Moo"," Mul"," Mun"," Mun"," Mur"," Mus"," Na"," Na"," Ned",
                     " Nes"," Nick"," No"," Nor"," Nos"," Nu"," O"," Omes"," Os"," Pal"," Pen"," Phil"," Po"," Pos"," Poy"," Pres"," Pus"," Quas"," Que"," Ra"," Rag",
                     " Ralt"," Ram"," Ray"," Ree"," Rem"," Rin"," Ris"," Ro"," Ro"," Ron"," Sa"," Sa"," See"," Ser"," Shal"," Sho"," Sho"," Sil"," Sit"," Spor",
                     " Sun"," Sur"," Sus"," Tar"," Tar"," Tas"," Tee"," Ten"," Ten"," Teth"," To"," To"," Ton"," Ton"," Tra"," Treb"," Tred"," Tue"," U"," Va"," Vak"," Ven",
                     " Ver"," Wal"," Web"," Wil"," Xor"," Y"," Yor"," Ys"," Zef"," Zell"," Zen"," Zer"," Zo"," Zo"," Zort",
                     "a","ael","af","ak","al","am","an","ar","baf","bar","bee","bel","ber","berd","bes",
                     "bo","bo","bol","bor","bran","brose","bru","bur","car","chor","cig","cla","da","da","dan","do","do","dock","doh","don","dor",
                     "dor","dre","drebb","e","eg","ek","el","el","end","er","er","es","eth","eth","ev","fal","fan","far","feg","fen","fi","ful",
                     "fum","ga","gahn","gaith","gar","gar","gen","ger","glen","go","go","gram","grink","gulf","ha","hag","hal","han","harg",
                     "ho","hol","hor","i","ig","in","ith","jax","jo","jur","ka","kan","kra","krac","ky","la","laf","lag","lap","le","lef","lem","lis",
                     "lo","lu","mal","mar","me","mer","mez","mez","mich","mil","mis","mo","mo","moo","mul","mun","mun","mur","mus","na","na","ned",
                     "nes","nick","no","nor","nos","nu","o","omes","os","pal","pen","phil","po","pos","poy","pres","pus","quas","que","ra","rag",
                     "ralt","ram","ray","ree","rem","rin","ris","ro","ro","ron","sa","sa","see","ser","shal","sho","sho","sil","sit","spor",
                     "sun","sur","sus","tar","tar","tas","tee","ten","ten","teth","to","to","ton","ton","tra","treb","tred","tue","u","va","vak","ven",
                     "ver","wal","web","wil","xor","y","yor","ys","zef","zell","zen","zer","zo","zo","zort","","","","","","","","","","","","","","","","","","","",""];

    my $title = [" from Above"," from Afar"," from Below"," the Adept"," the Albino"," the Antiquarian"," the Arcane"," the Archaic",
                 " the Barbarian"," the Batrachian"," the Battler"," the Bilious"," the Bold"," the Brave"," the Civilized"," the Collector",
                 " the Cryptic"," the Curious"," the Dandy"," the Daring"," the Decadent"," the Delver"," the Distant"," the Eldritch"," the Exotic",
                 " the Explorer"," the Fair"," the Fearless"," the Fickle"," the Foul"," the Furtive"," the Gambler"," the Ghastly"," the Gibbous"," the Great",
                 " the Grizzled"," the Gruff"," the Hairy"," the Bald"," the Haunted"," the Heavy"," the Lean"," the Hooded"," the Cowled"," the Hunter",
                 " the Imposing"," the Icthic"," the Irreverent"," the Loathsome"," the Loud"," the Quiet"," the Lovely"," the Mantled"," the Masked"," the Veiled",
                 " the Merciful"," the Merciless"," the Mercurial"," the Mighty"," the Morose"," the Mutable"," the Mysterious"," the Obscure"," the Old"," the Young",
                 " the Ominous"," the Peculiar"," the Perceptive"," the Pious"," the Quick"," the Ragged"," the Ready"," the Rough"," the Rugose"," the Scarred",
                 " the Searcher"," the Shadowy"," the Short"," the Tall"," the Steady"," the Uncanny"," the Unexpected"," the Unknowable"," the Verbose"," the Vigorous",
                 " the Wanderer"," the Wary"," the Weird"," the Blue"," the Green"," the Red"," the Black"," the White"," the Brown"," the Yellow"," the Dun"," the Ochre",
                 " the Purple"," the Violet"," the First"," the II"," the III"," the IV"," the V"," the VI"," the VII"," the VIII"," the IX"," the X"," of the Blue Cloak"," of the Green Cloak",
                 " of the Red Cloak"," of the Black Cloak"," of the White Cloak"," of the Brown Cloak"," of the Yellow Cloak"," of the Dun Cloak"," of the Ochre Cloak",
                 " of the Purple Cloak"," of the Violet Cloak"," of the North"," of the South"," of the East"," of the West"," of the Far North"," of the Far South",
                 " of the Far East"," of the Far West"," of the Arid Wastes"," of the Beetling Brow"," of the Cyclopean City"," of the Dread Wilds"," of the Eerie Eyes",
                 " of the Foetid Swamp"," of the Forgotten City"," of the Haunted Heath"," of the Hidden Valley"," of the Howling Hills",
                 " of the Jagged Peaks"," of the Menacing Mien"," of the Savage Isle"," of the Tangled Woods"," of the Watchful Eyes"," of Portown"," of the Northern Sea", " of Caladan",
                 " of the Meadow Country"," of the Cold Mountains"," of Labolinn"," of Amazonia"," of the Southern Jungle", " of the Enchanted Forest", " of the Desert of Irem",
                 " of Byrithium", " of Blackwood Forest", " of Ironbound Castle", " of the Realm", " of the Borderlands", " of the Black Forest", " of the Inland Sea", " of the Magic Isles",
                 " A"," Ael"," Af"," Ak"," Al"," Am"," An"," Ar"," Baf"," Bar"," Bee"," Bel"," Ber"," Berd"," Bes",
                 " Bo"," Bo"," Bol"," Bor"," Bran"," Brose"," Bru"," Bur"," Car"," Chor"," Cig"," Cla"," Da"," Da"," Dan"," Do"," Do"," Dock"," Doh"," Don"," Dor",
                 " Dor"," Dre"," Drebb"," E"," Eg"," Ek"," El"," El"," End"," Er"," Er"," Es"," Eth"," Eth"," Ev"," Fal"," Fan"," Far"," Feg"," Fen"," Fi"," Ful",
                 " Fum"," Ga"," Gahn"," Gaith"," Gar"," Gar"," Gen"," Ger"," Glen"," Go"," Go"," Gram"," Grink"," Gulf"," Ha"," Hag"," Hal"," Han"," Harg",
                 " Ho"," Hol"," Hor"," I"," Ig"," In"," Ith"," Jax"," Jo"," Jur"," Ka"," Kan"," Kra"," Krac"," Ky"," La"," Laf"," Lag"," Lap"," Le"," Lef"," Lem"," Lis",
                 " Lo"," Lu"," Mal"," Mar"," Me"," Mer"," Mez"," Mez"," Mich"," Mil"," Mis"," Mo"," Mo"," Moo"," Mul"," Mun"," Mun"," Mur"," Mus"," Na"," Na"," Ned",
                 " Nes"," Nick"," No"," Nor"," Nos"," Nu"," O"," Omes"," Os"," Pal"," Pen"," Phil"," Po"," Pos"," Poy"," Pres"," Pus"," Quas"," Que"," Ra"," Rag",
                 " Ralt"," Ram"," Ray"," Ree"," Rem"," Rin"," Ris"," Ro"," Ro"," Ron"," Sa"," Sa"," See"," Ser"," Shal"," Sho"," Sho"," Sil"," Sit"," Spor",
                 " Sun"," Sur"," Sus"," Tar"," Tar"," Tas"," Tee"," Ten"," Ten"," Teth"," To"," To"," Ton"," Ton"," Tra"," Treb"," Tred"," Tue"," U"," Va"," Vak"," Ven",
                 " Ver"," Wal"," Web"," Wil"," Xor"," Y"," Yor"," Ys"," Zef"," Zell"," Zen"," Zer"," Zo"," Zo"," Zort",
                 "a","ael","af","ak","al","am","an","ar","baf","bar","bee","bel","ber","berd","bes",
                 "bo","bo","bol","bor","bran","brose","bru","bur","car","chor","cig","cla","da","da","dan","do","do","dock","doh","don","dor",
                 "dor","dre","drebb","e","eg","ek","el","el","end","er","er","es","eth","eth","ev","fal","fan","far","feg","fen","fi","ful",
                 "fum","ga","gahn","gaith","gar","gar","gen","ger","glen","go","go","gram","grink","gulf","ha","hag","hal","han","harg",
                 "ho","hol","hor","i","ig","in","ith","jax","jo","jur","ka","kan","kra","krac","ky","la","laf","lag","lap","le","lef","lem","lis",
                 "lo","lu","mal","mar","me","mer","mez","mez","mich","mil","mis","mo","mo","moo","mul","mun","mun","mur","mus","na","na","ned",
                 "nes","nick","no","nor","nos","nu","o","omes","os","pal","pen","phil","po","pos","poy","pres","pus","quas","que","ra","rag",
                 "ralt","ram","ray","ree","rem","rin","ris","ro","ro","ron","sa","sa","see","ser","shal","sho","sho","sil","sit","spor",
                 "sun","sur","sus","tar","tar","tas","tee","ten","ten","teth","to","to","ton","ton","tra","treb","tred","tue","u","va","vak","ven",
                 "ver","wal","web","wil","xor","y","yor","ys","zef","zell","zen","zer","zo","zo","zort",
                 " from Above"," from Afar"," from Below"," the Adept"," the Albino"," the Antiquarian"," the Arcane"," the Archaic",
                 " the Barbarian"," the Batrachian"," the Battler"," the Bilious"," the Bold"," the Brave"," the Civilized"," the Collector",
                 " the Cryptic"," the Curious"," the Dandy"," the Daring"," the Decadent"," the Delver"," the Distant"," the Eldritch"," the Exotic",
                 " the Explorer"," the Fair"," the Fearless"," the Fickle"," the Foul"," the Furtive"," the Gambler"," the Ghastly"," the Gibbous"," the Great",
                 " the Grizzled"," the Gruff"," the Hairy"," the Bald"," the Haunted"," the Heavy"," the Lean"," the Hooded"," the Cowled"," the Hunter",
                 " the Imposing"," the Icthic"," the Irreverent"," the Loathsome"," the Loud"," the Quiet"," the Lovely"," the Mantled"," the Masked"," the Veiled",
                 " the Merciful"," the Merciless"," the Mercurial"," the Mighty"," the Morose"," the Mutable"," the Mysterious"," the Obscure"," the Old"," the Young",
                 " the Ominous"," the Peculiar"," the Perceptive"," the Pious"," the Quick"," the Ragged"," the Ready"," the Rough"," the Rugose"," the Scarred",
                 " the Searcher"," the Shadowy"," the Short"," the Tall"," the Steady"," the Uncanny"," the Unexpected"," the Unknowable"," the Verbose"," the Vigorous",
                 " the Wanderer"," the Wary"," the Weird"," the Blue"," the Green"," the Red"," the Black"," the White"," the Brown"," the Yellow"," the Dun"," the Ochre",
                 " the Purple"," the Violet"," the First"," the II"," the III"," the IV"," the V"," the VI"," the VII"," the VIII"," the IX"," the X"," of the Blue Cloak"," of the Green Cloak",
                 " of the Red Cloak"," of the Black Cloak"," of the White Cloak"," of the Brown Cloak"," of the Yellow Cloak"," of the Dun Cloak"," of the Ochre Cloak",
                 " of the Purple Cloak"," of the Violet Cloak"," of the North"," of the South"," of the East"," of the West"," of the Far North"," of the Far South",
                 " of the Far East"," of the Far West"," of the Arid Wastes"," of the Beetling Brow"," of the Cyclopean City"," of the Dread Wilds"," of the Eerie Eyes",
                 " of the Foetid Swamp"," of the Forgotten City"," of the Haunted Heath"," of the Hidden Valley"," of the Howling Hills",
                 " of the Jagged Peaks"," of the Menacing Mien"," of the Savage Isle"," of the Tangled Woods"," of the Watchful Eyes"," of Portown"," of the Northern Sea", " of Caladan",
                 " of the Meadow Country"," of the Cold Mountains"," of Labolinn"," of Amazonia"," of the Southern Jungle", " of the Enchanted Forest", " of the Desert of Irem",
                 " of Byrithium", " of Blackwood Forest", " of Ironbound Castle", " of the Realm", " of the Borderlands", " of the Black Forest", " of the Inland Sea",
                 " the Barbarian"," the Batrachian"," the Battler"," the Bilious"," the Bold"," the Brave"," the Civilized"," the Collector",
                 " the Cryptic"," the Curious"," the Dandy"," the Daring"," the Decadent"," the Delver"," the Distant"," the Eldritch"," the Exotic",
                 " the Explorer"," the Fair"," the Fearless"," the Fickle"," the Foul"," the Furtive"," the Gambler"," the Ghastly"," the Gibbous"," the Great",
                 " the Grizzled"," the Gruff"," the Hairy"," the Bald"," the Haunted"," the Heavy"," the Lean"," the Hooded"," the Cowled"," the Hunter",
                 " the Imposing"," the Icthic"," the Irreverent"," the Loathsome"," the Loud"," the Quiet"," the Lovely"," the Mantled"," the Masked"," the Veiled",
                 " the Merciful"," the Merciless"," the Mercurial"," the Mighty"," the Morose"," the Mutable"," the Mysterious"," the Obscure"," the Old"," the Young",
                 " the Ominous"," the Peculiar"," the Perceptive"," the Pious"," the Quick"," the Ragged"," the Ready"," the Rough"," the Rugose"," the Scarred",
                 " the Searcher"," the Shadowy"," the Short"," the Tall"," the Steady"," the Uncanny"," the Unexpected"," the Unknowable"," the Verbose"," the Vigorous",
                 " the Wanderer"," the Wary"," the Weird"," the Blue"," the Green"," the Red"," the Black"," the White"," the Brown"," the Yellow"," the Dun"," the Ochre",
                 " the Purple"," the Violet"," the First"," the II"," the III"," the IV"," the V"," the VI"," the VII"," the VIII"," the IX"," the X"," of the Blue Cloak"," of the Green Cloak",
                 " of the Red Cloak"," of the Black Cloak"," of the White Cloak"," of the Brown Cloak"," of the Yellow Cloak"," of the Dun Cloak"," of the Ochre Cloak",
                 " of the Purple Cloak"," of the Violet Cloak"," of the North"," of the South"," of the East"," of the West"," of the Far North"," of the Far South",
                 " of the Far East"," of the Far West"," of the Arid Wastes"," of the Beetling Brow"," of the Cyclopean City"," of the Dread Wilds"," of the Eerie Eyes",
                 " of the Foetid Swamp"," of the Forgotten City"," of the Haunted Heath"," of the Hidden Valley"," of the Howling Hills",
                 " of the Jagged Peaks"," of the Menacing Mien"," of the Savage Isle"," of the Tangled Woods"," of the Watchful Eyes"," of Portown"," of the Northern Sea", " of Caladan",
                 " of the Meadow Country"," of the Cold Mountains"," of Labolinn"," of Amazonia"," of the Southern Jungle", " of the Enchanted Forest", " of the Desert of Irem",
                 " of Byrithium", " of Blackwood Forest", " of Ironbound Castle", " of the Realm", " of the Borderlands", " of the Black Forest", " of the Inland Sea","","","","","","","","","","","","","","","","","","","",""];

    my $name = arnd($syllable) . arnd($syllable2) . arnd($title);
    return $name;
}

sub gen_equipment {
    my $args = shift;

    my $class = $$args{class};
    return $$equipment{$class}{roll_3d6()};
}

sub gen_title {
    my $args = shift;

    my $class = $$args{class};
    my $level = $$args{level};

    return $$classes{$class}{'level'}{$level}->[-1];
}

sub printable_class {
    my $args = shift;

    my $class = $$args{class};
    return "Fighting-Man" if $class eq 'fighter';
    return "Fighting-Man/Magic-User" if $class eq 'fighter/magic user';
    return "Magic-User" if $class eq 'magic user';
    return "Cleric" if $class eq 'cleric';
    return "Thief" if $class eq 'thief';
}

# Return an ordered hashref populated with random character data
sub gen_char
{
    my $args = shift;

    my $num_dice        = $$args{num_dice} || 3;
    my $str             = attribute_roll($num_dice);
    my $int             = attribute_roll($num_dice);
    my $wis             = attribute_roll($num_dice);
    my $con             = attribute_roll($num_dice);
    my $dex             = attribute_roll($num_dice);
    my $cha             = attribute_roll($num_dice);
    my $use_dex_ac      = $$args{use_dex_ac} || 0;
    my $race            = $$args{race} || gen_race();
    my $class           = $$args{class} || gen_class({'race' => $race, 'smart_class' => 1, 'str' => $str, 'int' => $int, 'wis' => $wis, 'dex' => $dex});

    # We make some allowance for poor ability scores here, given the
    # choice of class. This mimics the way an actual person chooses
    # class based on their prime requisite scores.
    $str = 9 if ( ($class eq 'fighter' || $race eq 'elf') && $str < 9 );
    $wis = 9 if ( $class eq 'cleric' && $wis < 9 );
    $dex = 9 if ( $class eq 'thief' && $dex < 9 );
    $int = 9 if ( ($class eq 'magic user' || $race eq 'elf') && $int < 9 );
    my $level           = $$args{level} || 1;
    $level = 1 if ($level < 1);
    $level = 3 if ($level > 3);
    my $melee_weapon    = gen_weapon({'class' => $class, 'race' => $race});
    my $missile_weapon  = gen_weapon({'class' => $class, 'race' => $race, 'type' => 'missile'});
    my $armor           = gen_armor({'class' => $class});
    my $shield          = gen_shield({'class' => $class});
    my $align           = $$args{align} || gen_align();
    $align = 'Neutral' if ($class eq 'thief');

    tie my %char, 'Tie::IxHash';
    %char = (
        'str'                 => $str,
        'int'                 => $int,
        'wis'                 => $wis,
        'con'                 => $con,
        'dex'                 => $dex,
        'cha'                 => $cha,
        'str_bonuses'         => '',
        'int_bonuses'         => $$int_bonuses{$int},
        'wis_bonuses'         => '',
        'con_bonuses'         => $$printable_con{$con}->[0],
        'dex_bonuses'         => $$dex_bonuses{$dex},
        'name'                => gen_name(),
        'class'               => $class,
        'race'                => $race,
        'race_abilities'      => $race_abilities{$race},
        'gender'              => gen_gender(),
        'age'                 => gen_age({'race' => $race,'level' => $level}),
        'deity'               => gen_deity({'class' => $class}),
        'level'               => $level,
        'title'               => gen_title({'class' => $class,'level' => $level}),
        'spells'              => gen_spells({'class' => $class, 'race' => $race, 'level' => $level}),
        'turn_undead'         => exists $$turn_undead{$class} ? join " ", @{$$turn_undead{$class}{$level}} : 'N/A',
        'sav'                 => gen_save({'class' => $class, 'race' => $race, 'level' => $level}),
        'xp_bonus'            => gen_xp_bonus({'class' => $class, 'level' => $level, 'str' => $str, 'int' => $int, 'wis' => $wis}),
        'melee_weapon'        => $melee_weapon,
        'melee_damage'        => gen_damage({'weapon' => $melee_weapon, 'type' => 'melee'}),
        'missile_weapon'      => $missile_weapon,
        'missile_damage'      => gen_damage({'weapon' => $missile_weapon,'type' => 'missile'}),
        'armor'               => $armor,
        'helmet'              => gen_helmet({'class' => $class}),
        'shield'              => $shield,
        'ac'                  => gen_ac({'armor' => $armor, 'shield' => $shield, 'dex' => $dex, 'use_dex_ac' => $use_dex_ac}),
        'hp'                  => gen_hp({'class' => $class, 'race' => $race, 'level' => $level, 'con' => $con}),
        'gp'                  => gen_gp({'level' => $level}),
        'languages'           => $$int_bonuses{$int}->[0],
        'chance_know'         => $$int_bonuses{$int}->[1],
        'min_spells'          => $$int_bonuses{$int}->[2],
        'max_spells'          => $$int_bonuses{$int}->[3],
        'max_retainers'       => $$cha_bonuses{$cha}->[0],
        'reaction'            => $$cha_bonuses{$cha}->[1],
        'morale'              => $$cha_bonuses{$cha}->[2],
        'alignment'           => $align,
        'equipment'           => gen_equipment({'class' => $class}),
        'skills'              => gen_thief_skills({'class' => $class, 'race' => $race, 'level' => $level}),
        'ancillary_equipment' => $$ancillary_equipment{$missile_weapon} || '',
    );

    return \%char;
}

sub print_bonuses {
    my $bonuses = shift;

    return '' if ( $bonuses eq '+0' );
    return " ($bonuses)" if ( $bonuses =~ m{\+\d} || $bonuses =~ m{\-\d} );
    return '';
}

sub print_saving_throws {
    my $saves = shift;

    return "   Spell or Staff: \t" . $saves->[0] . "\n   Magical Wand: \t" . $saves->[1] . "\n   Death Ray/Poison: \t" . $saves->[2] . "\n   Turned to Stone: \t" . $saves->[3] . "\n   Dragon Breath: \t" . $saves->[4];
}

sub print_thief_skills {
    my $skills = shift;

 #   return "   Open Lock: \t\t" . $skills->[0] . "%\n   Remove Trap: \t" . $skills->[1] . "%\n   Pick Pocket: \t" . $skills->[2] . "%\n   Move Silently: \t" . $skills->[3] . "%\n   Climb: \t\t" . $skills->[4] . "%\n   Hide in Shadows: \t" . $skills->[5] . "%\n   Hear Noise: \t\t" . $skills->[6];
return "   Thievery: \t\t" . $skills->[0] ;
}


# You can hard-code this call to gen_char to be whatever class or
# level you want, with the caveat that Elves won't work quite right
# yet above level 1/1. When we parameterize this, the user's choices
# will set these:
# 'use_dex_ac' = 1 if dexterity modifies armor class
# 'num_dice' is typically 3 or 4 - how many d6 we roll for each attribute
# 'race' is exactly one of human, halfling, elf, or dwarf
# 'class' is exactly one of 'figting man', thief, cleric, or 'fighter
/magic user'
my $char = gen_char({ 'use_dex_ac' => 0, 'level' => 1, num_dice => 3, class => '', 'race' => ''});

print "\n\nA Holmes Basic D&D Character\n";
print "*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~\n\n";
print "Name: ",gen_name(),"\n\n";
print "Level $$char{level} ",ucfirst($$char{race})," ",printable_class({'class' => $$char{class}}),"\n";
print "Title: ",ucfirst($$char{title}),"\n";
print "Alignment: $$char{alignment}\n";
print "Age: $$char{age}\n\n";

print "STR: ",sprintf('%2d',$$char{str}), print_bonuses($$char{str_bonuses}),"\n";
if ( $$char{class} =~ 'magic user' ) {
    print "INT: ",sprintf('%2d',$$char{int})," (% Know Spell: $$char{chance_know} Min: $$char{min_spells} Max: $$char{max_spells} Languages: $$char{languages})\n";
} else {
    print "INT: ",sprintf('%2d',$$char{int})," (Languages: $$char{languages})\n";
}

print "WIS: ",sprintf('%2d',$$char{wis}), print_bonuses($$char{wis_bonuses}),"\n";
print "CON: ",sprintf('%2d',$$char{con}), print_bonuses($$char{con_bonuses}),"\n";
print "DEX: ",sprintf('%2d',$$char{dex}), print_bonuses($$char{dex_bonuses}),"\n";
print "CHA: ",sprintf('%2d',$$char{cha})," (Followers: $$char{max_retainers})\n\n";

print "HP: $$char{hp}\n";
print "AC: $$char{ac}\n";
print "XP Bonus: ",$$char{xp_bonus} ? "$$char{xp_bonus}%" : 'None',"\n";
print "Saves: \n",print_saving_throws($$char{sav}),"\n\n";

print "Spells: ",ucfirst($$char{spells}),"\n\n" if ($$char{class} eq 'magic user' || $$char{race} eq 'elf');
print "Spells: None at 1st level\n\n" if ($$char{class} eq 'cleric');

if ($$char{class} eq 'cleric') {
    my @turn = split " ",$$char{turn_undead};
    print "Turn Undead:\n";
    print "  Skeleton: \t",$turn[0],"\n";
    print "  Zombie: \t",$turn[1],"\n";
    print "  Ghoul: \t",$turn[2],"\n\n";
}

print "Armor: ",ucfirst($$char{armor}),"\n";
print "Shield: ",$$char{shield} eq 'shield' ? 'Yes' : 'None',"\n";
print "Helm: ",$$char{helmet} eq 'helmet' ? 'Yes' : 'None',"\n\n";

print "Weapons:\n $$char{melee_weapon}\n";
print " $$char{missile_weapon}\n" unless ($$char{melee_weapon} eq $$char{missile_weapon} || $$char{missile_weapon} eq 'None');

print "\nEquipment:\n";
print " ",join "\n",split ",",$$char{equipment};
print "\n $$char{ancillary_equipment}\n";

print "\nThief Skills: \n",print_thief_skills($$char{skills}),"\n\n" if ($$char{class} eq 'thief');

if ( $$char{race} ne 'human' ) {
    print "\nRacial Abilities:\n";
    print "$$char{race_abilities}\n\n";
}
