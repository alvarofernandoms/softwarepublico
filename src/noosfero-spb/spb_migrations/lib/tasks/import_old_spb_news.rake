require 'csv'
require 'net/http'

namespace :spb do

  desc "Import news from CSV file"
  task :import_old_spb_news => :environment do

    error ENV["CSV_FILE"].blank?, "csv file with all the news is required to run this task!
      Ex.: rake spb:import_old_spb_news CSV_FILE=my_path/my_csv_file.csv."

    spb_profile = Profile['spb']
    error spb_profile.blank?, "There is no SPB community."
    spb_blog = spb_profile.articles.find_by :slug => "noticias"
    error spb_blog.nil?, "There is no SPB blog named 'noticias' in the SPB community to import the news to."

    CSV.foreach(ENV["CSV_FILE"], encoding: "UTF-8", headers: true, col_sep: "|", quote_char: "\"") do |row|
      date = DateTime.parse(row["max"])
      body = row["content"]
      body.gsub!("softwarepublico.gov","antigo.softwarepublico.gov") unless body.blank?
      body.gsub!("www.","") unless body.blank?

      attrs={
        :published_at => date,
        :published => (row["publish_status"] == "ready"),
        :body => body,
        :highlighted => true,
        :parent => spb_blog,
        :profile => spb_profile,
        :name => row["title"]
      }

      article = Article.find_by(:slug => row["title"].to_slug)
      if article.blank?
        article = TinyMceArticle.new(attrs)
        article.created_at = date
        article.save!
      else
        article.path = "#{spb_blog.slug}/#{child.slug}"
        article.parent = spb_blog
        article.save!
      end

      puts "#{spb_blog.slug}: Importing article: #{article.name}..."
    end

  end

  def error failure_condition, msg="ERROR!!"
    if failure_condition
      puts msg
      exit 1
    end
  end
end
