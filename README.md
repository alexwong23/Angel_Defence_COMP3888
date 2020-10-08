# COMP3888 Capstone Project #

We created two arenas on the CodeCombat platform: Angel Defence 1 & Angel Defence 2

# How to access our arenas as players

* Access Angel Defence 1:
Click the [link](https://direct.codecombat.com/play/level/angel-defence-1)

* Access Angel Defence 2:
Click the [link](https://direct.codecombat.com/play/level/angel-defence-2)

# How to play our arenas

* Play Angel Defence 1:  


        Programming language for player: Python  

        Target users: CS1-3 CodeCombat students

        Goal: Make your angel survive longer than your opponent.

        In this arena, you are allowed to spawn 3 types of
        allies: "warrior", "archer" and "wizard"  

        Use game.spawn("<unit type>",<position number>)  
        to spawn a unit at a specific position.

        you can spawn units at positions from 0 to 5.  

        You have 100 gold at the beginning of the game.  

        Spawn allies takes your gold!
        Earn gold by killing enemies!

* Play Angel Defence 2:  

        Programming language for player: Python

        Target users: CS4-6 CodecCombat students

        Goal: Destroy the opponent's angel before yours is destroyed.  

        In this arena, you are allowed to spawn 9 types of allies:
            "warrior", "knight", "thief",
            "archer", "wizard", "thrower",
            "buffer", "warlock", "peasant"

        You have 50 gold at the beginning of the game.
        Spawn allies using your gold!
        Earn gold by killing the opponent's units or neutrals!

        Methods to use:
        - game.spawn() to spawn a unit
        - game.setActionFor() to assign the unitType a behaviour

        Additional Methods to use:
        - game.setActionForUnit() to assign one unit a behaviour
        - game.changeActionFor() to change behaviour of the unitType
        - game.changeActionForUnit() to change behaviour of one unit

# How to access the source code (works for both arenas)

The source code is contained in the CodeCombat level editor environment.

To access the source code:

1. Go to the link: https://direct.codecombat.com/editor/level.
2. Add the name of the arena after "editor/level", for example, https://direct.codecombat.com/editor/level/angel-defence-2
3. In the level editor, double click the "well".
4. In the left side **COMPONENTS** bar, click **misc.Referee**.
5. The source code is in the **extraCode** section under misc.Referee.
