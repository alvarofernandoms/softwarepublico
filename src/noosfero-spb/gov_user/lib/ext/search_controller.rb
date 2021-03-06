require_dependency 'search_controller'

class SearchController

  def communities
    @titles[:communities] = _("Communities Search")
    delete_communities = []
    valid_communities_string = Community.get_valid_communities_string
    Community.all.each{|community| delete_communities << community.id unless eval(valid_communities_string)}

    @scope = visible_profiles(Community)
    @scope = @scope.where(["id NOT IN (?)", delete_communities]) unless delete_communities.empty?

    full_text_search
  end

  def institutions
    @titles[:institutions] = _("Institutions Search")
    results = filter_communities_list{|community| community.institution?}
    results = results.paginate(:per_page => 24, :page => params[:page])
    @searches[@asset] = {:results => results}
    @search = results
  end

  def filter_communities_list
    unfiltered_list = visible_profiles(Community)

    unless params[:query].nil?
      unfiltered_list = unfiltered_list.select do |com|
        com.name.downcase =~ /#{params[:query].downcase}/
      end
    end

    communities_list = []
    unfiltered_list.each do |profile|
      if profile.class == Community && !profile.is_template? && yield(profile)
        communities_list << profile
      end
    end

    communities_list
  end
end
