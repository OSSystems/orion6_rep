class CreateTimeClockTable < ActiveRecord::Migration
  def self.up
    create_table :time_clocks do |t|
      t.string   :description
      t.string   :ip
      t.integer  :tcp_port
      t.integer  :number
      t.timestamps
    end
  end

  def self.down
    drop_table :time_clocks
  end
end
