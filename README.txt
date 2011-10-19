Chimaera EPGP
An implementation of the EPGP raid loot allocation system.
<Jug@Steampike>

Introduction
EPGP is a system designed to fairly allocate loot to raid members.  It's based on the principal that the more effort you put in to the guild, the more loot you will be awarded.  What "effort" means is up to your guild officers to decide, time spent raiding is one measure of effort, but "Effort Points" can be awarded to players for anything, helping the guild out with administration or impressive skill in a raid for example.

EPGP overcomes some of the complaints players have with other loot "points" based systems.  It doesn't unfairly penalise players who raid less regularly than others and it doesn't unfairly favour long term guild members over newer recruits.  It seeks to be a fair system which keeps everyone happy.

Let's look at an example of how the EPGP system allocates loot fairly.  Suppose we have two players, "Alfar" and "Enve".  Over the course of a month Alfar attends twice as many raids as Enve.  Let's assume that everytime they are in a raid together they both want the same loot.  At the end of the month, it would work out that Alfar has been awarded twice the amount of loot as Enve.  Which seems perfectly fair doesn't it?  Alfar put in twice the time that Enve did, so he gets twice the amount of loot.  If Alfar received 10 items, Enve would get 5.

The example above has been overly simplified to illustrate the general principal.  The actual reality is slightly more complex, and we'll look at why in more detail later.

For the moment it's enough to understand that EPGP's purpose is to fairly distribute loot and remove the element of random chance from who gets awarded loot.


How does it work?
EPGP is derived from the terms "Effort Points" and "Gear Points".  Players earn Effort Points (EP) for putting in effort.  Players gain Gear Points (GP) when they are awarded loot.  The relationship between EP and GP is used to calculate the "Loot Priority" when more than one player wants an item drop.  The player with the highest priority (PR) gets the loot.

The formula is quite simple:  

  PR = EP / GP

or

  Loot Priority = Effort Points divided by Gear Points

This has the basic effect that being awarded loot lowers your Loot Priority, the more loot you are awarded the lower your Loot Priority will fall.  Conversely the less loot you are awarded the higher your Loot Priority will rise, ensuring everyone gets there chance of being awarded loot.
  

Ensuring Fairness
There are some subtleties to the system to ensure fairness.

Decay.
Effort Points decay over time.  This means that "effort" put in two months ago is worth slightly less than "effort" put in today.  The purpose of this is so that long term raiders who don't need much loot don't build up an unfair advantage over newer members.  

Gear Points.
Not all loot is the same.  A "Sword of Uberness" is clearly better than a "Ring of Crapyness".  To account for this, different loot items can be given a different "Gear Points" values.  For example, let's say Enve and Alfar have exactly the same Loot Priority.  Enve loots a "Ring of Crapyness" and Alfar loots a "Sword of Uberness".  Alfar would gain more Gear Points than Enve and his Loot Priority would consequently be lower than Enve's, thus giving Enve priority over the next loot.

Actual specific GP values for individual items is for the guild officers to decide.  If the "Ring of Crappyness" had a GP of 100 and the "Sword of Uberness" had a GP of 500, it would mean that looting five rings would be exactly equivalent to looting one sword, in terms of the effect of a players Loot Priority.

Minimum EP and Base GP
A new player who earns some Effort Points would have an infinitely high Loot Priority if they have never accrued any Gear Points by looting an item.  To avoid this problem, the system has a "Base GP" value which sets the lowest value to which GP can fall.  

As a matter of fairness, a guild may not want brand new players to have loot priority over more established members, until they have proven themselves by completing some raids.  To facilitate this, the system provides a "Minimum EP" value.  A player whose Effort Points do not yet meet the "Minimum EP" requirement will always have a lower Loot Priority than players that do have more than the minimum required Effort Points, regardless of what their actual Loot Priority is when calculated mathematically.

  
Credits
The addon was originally designed for use within the Chimaera guild on Steampike:
	Designed and Coded by Jug
	Initial idea by Enve.
	Development testing by the officer team

Toolbar button icons designed by dryicons.com
Based on the EPGP system described at epgpweb.com
