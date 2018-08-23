#!/usr/local/bin/ruby
require 'claide'
class SvnCommand < CLAide::Command
    self.abstract_command = true
  
    self.description = 'Make delicious beverages from the comfort of your' \
      'terminal.'
  
    # This would normally default to `beverage-make`, based on the class’ name.
    self.command = 'make'
  
    def self.options
      [
        ['--no-milk', 'Don’t add milk to the beverage'],
        ['--sweetener=[sugar|honey]', 'Use one of the available sweeteners'],
      ].concat(super)
    end
  
    def initialize(argv)
      @add_milk = argv.flag?('milk', true)
      @sweetener = argv.option('sweetener')
      super
    end
  
    def validate!
      super
      if @sweetener && !%w(sugar honey).include?(@sweetener)
        help! "`#{@sweetener}' is not a valid sweetener."
      end
    end
  
    def run
      puts '* Boiling water…'
      sleep 1
      if @add_milk
        puts '* Adding milk…'
        sleep 1
      end
      if @sweetener
        puts "* Adding #{@sweetener}…"
        sleep 1
      end
    end
  
    # This command uses an argument for the extra parameter, instead of
    # subcommands for each of the flavor.
    class Tea < SvnCommand
      self.summary = 'Drink based on cured leaves'
  
      self.description = <<-DESC
        An aromatic beverage commonly prepared by pouring boiling hot
        water over cured leaves of the Camellia sinensis plant.
        The following flavors are available: black, green, oolong, and white.
      DESC
  
      self.arguments = [
        CLAide::Argument.new(:FLAVOR, false),
      ]
  
      def self.options
        [['--iced', 'the ice-tea version']].concat(super)
      end
  
      def initialize(argv)
        @flavor = argv.shift_argument
        @iced = argv.flag?('iced')
        super
      end
  
      def validate!
        super
        if @flavor.nil?
          help! 'A flavor argument is required.'
        end
        unless %w(black green oolong white).include?(@flavor)
          help! "`#{@flavor}' is not a valid flavor."
        end
      end
  
      def run
        super
        puts "* Infuse #{@flavor} tea…"
        sleep 1
        if @iced
          puts '* Cool off…'
          sleep 1
        end
        puts '* Enjoy!'
      end
    end
  
    # Unlike the Tea command, this command uses subcommands to specify the
    # flavor.
    #
    # Which one makes more sense is up to you.
    class Coffee < SvnCommand
      self.abstract_command = true
  
      self.summary = 'Drink brewed from roasted coffee beans'
  
      self.description = <<-DESC
        Coffee is a brewed beverage with a distinct aroma and flavor
        prepared from the roasted seeds of the Coffea plant.
      DESC
  
      def run
        super
        puts "* Grinding #{self.class.command} beans…"
        sleep 1
       
        puts '* Brewing coffee…'
        sleep 1
        puts '* Enjoy!'
      end
  
      class BlackEye < Coffee
        self.summary = 'A Black Eye is dripped coffee with a double shot of ' \
          'espresso'
      end
  
      class Affogato < Coffee
        self.summary = 'A coffee-based beverage (Italian for "drowned")'
      end
  
      class CaPheSuaDa < Coffee
        self.summary = 'A unique Vietnamese coffee recipe'
      end
  
      class RedTux < Coffee
        self.summary = 'A Zebra Mocha combined with raspberry flavoring'
      end
    end
  end
  
  