require "./macros/*"
require "./dsl/*"

module Optarg
  abstract class Model
    macro inherited
      {%
        if @type.superclass == ::Optarg::Model
          is_root = true
          super_option = "Optarg::Option"
          super_argument = "Optarg::Argument"
          super_handler = "Optarg::Handler"
          super_option_metadata = "Optarg::Metadata"
          super_argument_metadata = "Optarg::Metadata"
          super_handler_metadata = "Optarg::Metadata"
          super_argument_value_list = "Optarg::ArgumentValueList"
          super_parser = "Optarg::Parser"
        else
          is_root = false
          super_option = "#{@type.superclass}::Option"
          super_argument = "#{@type.superclass}::Argument"
          super_handler = "#{@type.superclass}::Handler"
          super_option_metadata = "#{@type.superclass}::Option::Metadata"
          super_argument_metadata = "#{@type.superclass}::Argument::Metadata"
          super_handler_metadata = "#{@type.superclass}::Handler::Metadata"
          super_argument_value_list = "#{@type.superclass}::ArgumentValueList"
          super_parser = "#{@type.superclass}::Parser"
        end %}

      abstract class Option < ::{{super_option.id}}
        abstract class Metadata < ::{{super_option_metadata.id}}
        end
      end

      abstract class Argument < ::{{super_argument.id}}
        abstract class Metadata < ::{{super_argument_metadata.id}}
        end
      end

      abstract class Handler < ::{{super_handler.id}}
        abstract class Metadata < ::{{super_handler_metadata.id}}
        end
      end

      class ArgumentValueList < ::{{super_argument_value_list.id}}
      end

      @@__self_options = {} of ::String => ::Optarg::Option
      @@__options : ::Hash(::String, ::Optarg::Option)?
      def self.__options
        @@__options ||= begin
          {% if is_root %}
            h = {} of ::String => ::Optarg::Option
          {% else %}
            h = ::{{@type.superclass}}.__options.dup
          {% end %}
          h.merge(@@__self_options)
        end
      end

      @@__self_arguments = {} of ::String => ::Optarg::Argument
      @@__arguments : ::Hash(::String, ::Optarg::Argument)?
      def self.__arguments
        @@__arguments ||= begin
          {% if is_root %}
            h = {} of ::String => ::Optarg::Argument
          {% else %}
            h = ::{{@type.superclass}}.__arguments.dup
          {% end %}
          h.merge(@@__self_arguments)
        end
      end

      @@__self_handlers = {} of ::String => ::Optarg::Handler
      @@__handlers : ::Hash(::String, ::Optarg::Handler)?
      def self.__handlers
        @@__handlers ||= begin
          {% if is_root %}
            h = {} of ::String => ::Optarg::Handler
          {% else %}
            h = ::{{@type.superclass}}.__handlers.dup
          {% end %}
          h.merge(@@__self_handlers)
        end
      end

      @@__self_terminators = {} of ::String => ::Optarg::Terminator
      @@__terminators : ::Hash(::String, ::Optarg::Terminator)?
      def self.__terminators
        @@__terminators ||= begin
          {% if is_root %}
            h = {} of ::String => ::Optarg::Terminator
          {% else %}
            h = ::{{@type.superclass}}.__terminators.dup
          {% end %}
          h.merge(@@__self_terminators)
        end
      end

      class Parser < ::{{super_parser.id}}
        @parsed_args = ArgumentValueList.new
        def parsed_args
          @parsed_args as ArgumentValueList
        end

        def model
          ::{{@type}}
        end

        def data
          @data as ::{{@type}}
        end
      end

      def self.parse(argv)
        new(argv).__parse
      end

      def __parse
        __parser.parse
        self
      end

      def __parser
        @__parser as Parser
      end

      def __new_parser(argv)
        Parser.new(self, argv)
      end
    end

    @__parser : Parser?

    def initialize(argv)
      @__parser = __new_parser(argv)
    end

    def __args; __parser.parsed_args; end
    def args; __args; end

    def __unparsed_args; __parser.unparsed_args; end
    def unparsed_args; __unparsed_args; end

    def __parsed_nodes; __parser.parsed_nodes; end
    def parsed_nodes; __parsed_nodes; end

    private def __yield
      yield
    end

    def parse
      __parse
    end

    def __parser
      raise "Should never be called."
    end

    def self.__terminator?(name)
      self.__terminators.keys.includes?(name)
    end
  end
end
