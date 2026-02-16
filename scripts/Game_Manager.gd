extends Node

var resources := 0
var money := 0

signal enter_shop
signal enter_resources

func add_money(amount: int):
	money += amount
	
func add_resources(amount: int):
	resources += amount
	
func clear_money():
	money = 0
	
func clear_resources():
	resources = 0
