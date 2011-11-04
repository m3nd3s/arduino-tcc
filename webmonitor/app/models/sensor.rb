#coding: utf-8
class Sensor < ActiveRecord::Base
    validates_presence_of :sid
    validates_numericality_of :sid
    validates_presence_of :name

    has_many :temperatures

    def alert
      read_attribute(:alert) ? "Sim" : "Não"
    end
end
