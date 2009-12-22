class History < ActiveRecord::Base
  belongs_to :page
  belongs_to :content
  belongs_to :user

  validates_associated :content
  validates_presence_of :user_id
  after_save :update_page_updated_at

  named_scope :heads, lambda{|*opts|
    heads_sql = <<-SQL
  SELECT hs.id
  FROM   #{quoted_table_name} AS hs
  INNER JOIN (
    SELECT
      h.page_id AS page_id,
      MAX(h.revision) AS revision
    FROM histories AS h
    GROUP BY h.page_id
  ) AS heads
  ON hs.page_id = heads.page_id AND hs.revision = heads.revision
SQL
    # or/ {:conditions => ["#{quoted_table_name}.id IN (#{heads_sql})"]}
    ids = connection.select_all(heads_sql).map{|h| Integer(h["id"]) }
    {:conditions => ["#{quoted_table_name}.id IN (?)", ids ]}
  }

  def self.find_all_by_head_content(keyword, only_head = true)
    heads.find(:all, :include => :content,
                     :conditions => ["contents.data LIKE ?", "%#{keyword}%"])
  end

  private
  def update_page_updated_at
    page.touch
    page.last_modified_user_id = self.user_id
    page.save
  end

end