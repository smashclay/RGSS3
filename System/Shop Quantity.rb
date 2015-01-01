#==============================================================================
# ** Quasi Shop Quantity v1.0
#==============================================================================
#  Adds the ability to create shops that have items with quantities, as well
# as being able to restock these shops.
#==============================================================================
# How to install:
#  - Place about Main and below Materials
#  - Follow instructions below
#==============================================================================
module Quasi
  module ShopQuantity
#==============================================================================
# Instructions:
#  To open a Shop Quantity use the following script call:
#    open_shopquantity(SHOPID, purchase only?)
#      -Set SHOPID to the shop you want to open (make sure it's set up below)
#      -purchase only? should be true or false
#
#  To restock a shop use the following script call:
#    restock_shopquantity(SHOPID, item=nil)
#      -Set SHOPID to the shop you want to open (make sure it's set up below)
#      -Leave item blank for overall stock, or set it to the items index from
#      the shop array to get the items stock, or use its :typeid
#
#  To find out how much stock a shop has use the following script call:
#    stock_shopquantity(SHOPID, item=nil)
#     -Set SHOPID to the shop you are checking the stock for
#     -Leave item blank for overall stock, or set it to the items index from
#      the shop array to get the items stock, or use its :typeid
#     *Note* infinite items return 0
#
# Example:
#   open_shopquantity(1)
#     This will open shop 1
#
#   restock_shopquantity(1)
#     This will restock shop 1
#
#   restock_shopquantity(1, :item1)
#     This will restock :item1 from shop 1
#
#   stock_shopquantity(1)
#     This would return the total stock of all items from shop 1
#
#   stock_shopquantity(1, 0)
#     This would return the stock for index 0 from shop 1 (very first item)
#
#   stock_shopquantity(1, :item1)
#     This would return the stock for :item1 from shop 1
#
# Setup:
#  REMOVEOUTOFSTOCK
#     Set this to true ot false, when true the items that are out of stock (0)
#    are not shown inside the shop menu, when false they will still show but
#    they will be disabled.
#==============================================================================
    REMOVEOUTOFSTOCK = true
    
    SHOPS = [] # DO NOT CHANGE THIS ONE =======================================
#==============================================================================
# Make shops below with the following format:
#   SHOPS[SHOPID] = [
#     [:TYPEID, QUANTITY, PRICE], #<- Don't forget the comma at the end!
#     [:TYPEID, QUANTITY, PRICE]  #<- Last item shouldn't have a comma!!
#   ]
# SHOPID   => The ID for the shop you are making, you'll use this ID to open
#             the shop and shop_restock it.
# :TYPEID  => :TYPE can be :item, :wep, or :arm, and ID is the id of the item
#             from the database.  Ex :item1 would be potion from default database
# QUANTITY => How much of that item should the shop have in stock.  Set this to
#             -1 for infinite Quantity.
# PRICE    => The price for the item inside the shop.  This one is optional and
#             if left out, it will use the default price.
#
# *Note* This is making the default shop settings, whenever you restock a shop
# it will never restock higher then the quantity set here.
#==============================================================================
    SHOPS[1] = [
      [:item1, -1, 10],
      [:item2, 5]
    ]
    SHOPS[2] = [
      [:wep1, 5],
      [:wep2, 2],
      [:arm1, 5],
      [:arm2, 2]
    ]
  end
end
#==============================================================================
# Change Log
#------------------------------------------------------------------------------
# v1.0 - 12/31/4
#      - Restock methods
#      - Release version
# --
# v0.8 - 12/30/14
#      - Added few more methods
# --
# v0.5 - Pre-Released
#==============================================================================#
# By Quasi (http://quasixi.com/) || (https://github.com/quasixi/RGSS3)
#  - 12/27/14
#==============================================================================#
#   ** Stop! Do not edit anything below, unless you know what you      **
#   ** are doing!                                                      **
#==============================================================================#
$imported = {} if $imported.nil?
$imported["Quasi_ShopQuantity"] = 1

#==============================================================================
# ** Game_System
#------------------------------------------------------------------------------
#  This class handles system data. It saves the disable state of saving and
# menus. Instances of this class are referenced by $game_system.
#==============================================================================
 
class Game_System
  attr_accessor :shopquantity
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias :qsq_gs_init    :initialize
  def initialize
    @shopquantity = []
    qsq_gs_init
  end
  #--------------------------------------------------------------------------
  # * Initialize the shop
  #--------------------------------------------------------------------------
  def shopquantity(shopid)
    unless @shopquantity[shopid]
      @shopquantity[shopid] = []
      shop = Quasi::ShopQuantity::SHOPS[shopid]
      shop.each {|item| shop_add(shopid, item)}
    end
    return @shopquantity[shopid]
  end
  #--------------------------------------------------------------------------
  # * Add items into the shop
  #--------------------------------------------------------------------------
  def shop_add(shopid, item)
    typeid = item[0].to_s
    typehash = {"item" => 0, "wep" => 1, "arm" => 2}
    type = typehash[typeid.gsub(/[0-9]/, "")]
    id = typeid.gsub(/[item|wep|arm]/,"").to_i
    stock = item[1].to_i
    price = item[2] ? item[2] : 0
    customprice = price != 0 ? 1 : 0
    @shopquantity[shopid] << [type, id, customprice, price, stock]
  end
  #--------------------------------------------------------------------------
  # * Restocks the shop
  #--------------------------------------------------------------------------
  def shop_restock(shopid, item=nil)
    if item.is_a?(Integer)
      return unless shopquantity(shopid)[item]
      shopquantity(shopid)[item][4] = Quasi::ShopQuantity::SHOPS[shopid][item][1]
    elsif item.is_a?(Symbol)
      shop = Quasi::ShopQuantity::SHOPS[shopid]
      indexlist = []
      shop.each {|item| indexlist << item[0]}
      index = indexlist.index{|i| i == item}
      return unless index
      shop_restock(shopid, index)
    else
      @shopquantity[shopid] = nil
      shopquantity(shopid)
    end
  end
  #--------------------------------------------------------------------------
  # * Counts shop stock
  # ignores infinite items
  #--------------------------------------------------------------------------
  def shop_count_stock(shopid)
    stock = 0
    shopquantity(shopid).each_index do |item|
      stock += shop_count_item_stock(shopid, item)
    end
    return stock
  end
  #--------------------------------------------------------------------------
  # * Counts item stock from shop
  # inifinite items return 0
  #--------------------------------------------------------------------------
  def shop_count_item_stock(shopid, item)
    return 0 unless shopquantity(shopid)[item]
    stock = shopquantity(shopid)[item][4]
    return stock == -1 ? 0 : stock
  end
end

#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  An interpreter for executing event commands. This class is used within the
# Game_Map, Game_Troop, and Game_Event classes.
#==============================================================================
 
class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Shop Processing
  #--------------------------------------------------------------------------
  def open_shopquantity(shopid, purchase=false)
    return if $game_party.in_battle
    return unless Quasi::ShopQuantity::SHOPS[shopid]
    goods = $game_system.shopquantity(shopid)
    SceneManager.call(Scene_ShopQuantity)
    SceneManager.scene.prepare(goods, purchase)
    Fiber.yield
  end
  #--------------------------------------------------------------------------
  # * Restock Shops
  #--------------------------------------------------------------------------
  def restock_shopquantity(shopid, item=nil)
    $game_system.shop_restock(shopid, item)
  end
  #--------------------------------------------------------------------------
  # * Returns the Shops stock
  # if item value is set it will return the stock of that item from shop
  #--------------------------------------------------------------------------
  def stock_shopquantity(shopid, item=nil)
    if item.is_a?(Integer)
      return $game_system.shop_count_item_stock(shopid, item)
    elsif item.is_a?(Symbol)
      typeid = item.to_s
      typehash = {"item" => 0, "wep" => 1, "arm" => 2}
      type = typehash[typeid.gsub(/[0-9]/, "")]
      id = typeid.gsub(/[item|wep|arm]/,"").to_i
      shop = $game_system.shopquantity(shopid)
      item = shop.select{|i| i[0] == type && i[1] == id}
      return 0 if item.empty?
      return item[0][4]
    else
      return $game_system.shop_count_stock(shopid)
    end
  end
  #--------------------------------------------------------------------------
  # * Check if shop is empty
  #--------------------------------------------------------------------------
  def shopquantity_empty?(shopid)
    return $game_system.shop_count_stock(shopid) == 0 ? true : false
  end
end

#==============================================================================
# ** Scene_Shop
#------------------------------------------------------------------------------
#  This class performs shop screen processing.
#==============================================================================

class Scene_ShopQuantity < Scene_Shop
  #--------------------------------------------------------------------------
  # * Create Purchase Window
  #--------------------------------------------------------------------------
  def create_buy_window
    wy = @dummy_window.y
    wh = @dummy_window.height
    @buy_window = Window_ShopQuantity.new(0, wy, wh, @goods)
    @buy_window.viewport = @viewport
    @buy_window.help_window = @help_window
    @buy_window.status_window = @status_window
    @buy_window.hide
    @buy_window.set_handler(:ok,     method(:on_buy_ok))
    @buy_window.set_handler(:cancel, method(:on_buy_cancel))
  end
  #--------------------------------------------------------------------------
  # * Execute Purchase
  #--------------------------------------------------------------------------
  def do_buy(number)
    unless @buy_window.infinite(@item)
      @goods[@buy_window.itemindex(@item)][4] -= number
    end
    $game_party.lose_gold(number * buying_price)
    $game_party.gain_item(@item, number)
  end
  #--------------------------------------------------------------------------
  # * Execute Sale
  #--------------------------------------------------------------------------
  def do_sell(number)
    $game_party.gain_gold(number * selling_price)
    $game_party.lose_item(@item, number)
  end
  #--------------------------------------------------------------------------
  # * Get Maximum Quantity Buyable
  #--------------------------------------------------------------------------
  def max_buy
    space = $game_party.max_item_number(@item) - $game_party.item_number(@item)
    max = [space, @buy_window.quantity(@item)].min
    max = space if @buy_window.infinite(@item)
    buying_price == 0 ? max : [max, money / buying_price].min
  end
end

#==============================================================================
# ** Window_ShopBuy
#------------------------------------------------------------------------------
#  This window displays a list of buyable goods on the shop screen.
#==============================================================================

class Window_ShopQuantity < Window_ShopBuy
  #--------------------------------------------------------------------------
  # * Create Item List
  #--------------------------------------------------------------------------
  def make_item_list
    @data = []
    @price = {}
    @quantity = {}
    @itemindex = {}
    @infinite = {}
    @shop_goods.each_with_index do |goods, index|
      case goods[0]
      when 0;  item = $data_items[goods[1]]
      when 1;  item = $data_weapons[goods[1]]
      when 2;  item = $data_armors[goods[1]]
      end
      if item
        next if goods[4] == 0 && Quasi::ShopQuantity::REMOVEOUTOFSTOCK
        @data.push(item)
        @price[item] = goods[2] == 0 ? item.price : goods[3]
        @quantity[item] = goods[4]
        @itemindex[item] = index
        @infinite[item] = goods[4] < 0 ? true : false
      end
    end
    select(@data.size-1) unless @data[index]
  end
  #--------------------------------------------------------------------------
  # * Get Quantity of Item
  #--------------------------------------------------------------------------
  def quantity(item)
    @quantity[item]
  end
  #--------------------------------------------------------------------------
  # * Get Infinite Quantity of Item
  #--------------------------------------------------------------------------
  def infinite(item)
    @infinite[item]
  end
  #--------------------------------------------------------------------------
  # * Get index of Item in Quantity Shop
  #--------------------------------------------------------------------------
  def itemindex(item)
    @itemindex[item]
  end
  #--------------------------------------------------------------------------
  # * Display in Enabled State?
  #--------------------------------------------------------------------------
  def enable?(item)
    return false unless item
    return super if infinite(item)
    return quantity(item) > 0 && super
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    rect = item_rect(index)
    draw_item_name(item, rect.x, rect.y, enable?(item))
    rect.width -= 4
    unless infinite(item)
      draw_text(rect.x - 74, rect.y, rect.width, rect.height, quantity(item), 2)
    end
    draw_text(rect, price(item), 2)
  end
end
