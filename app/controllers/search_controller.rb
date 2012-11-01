class SearchController < ApplicationController
  include Blacklight::Controller
  include Blacklight::Catalog
  include Blacklight::Configurable
  include BlacklightRangeLimit::ControllerOverride
  layout 'quicksearch'

  CATEGORY_ORDER = %w{catalog articles_journals articles academic_commons ebooks ejournals lweb catalog_ebooks catalog_ejournals catalog_dissertations articles_dissertations articles_newspapers ac_dissertations}

  def index
    @results = []
    session['search'] = params
    session['search']['s.q'] = params['q'] if params['q'] 
    params['categories'] = ['catalog', 'academic_commons', 'articles', 'lweb']

    raise('test') if params['throw_error']

    if params['q'].to_s.strip.empty? 
      flash[:error] = "You cannot search with an empty string." if params['commit']
    else
      active_categories = CATEGORY_ORDER.select { |cat| params['categories'].listify.include?(cat) }



      case active_categories.length 
      when 0
        flash[:error] = "You must select a category to search."
      when 1
        redirect_to search_url_for(active_categories.first, params)
      else
        @results= get_results(active_categories)
       

      end


    end

  end

  def newspapers
    
    session['search'] = params
    session['search']['s.q'] = params['q'] if params['q']
    params['categories'] = ['articles_newspapers', 'catalog_databases']

    @results = {}
    if params['q'].to_s.strip.empty? 
      flash[:error] = "You cannot search with an empty string." if params['commit']
    else
      @results = get_results(params['categories'])

    end
  end

  def articles_journals
    
    session['search'] = params
    session['search']['s.q'] = params['q'] if params['q']
    params['categories'] = ['articles', 'catalog_ejournals']

    @results = {}
    if params['q'].to_s.strip.empty? 
      flash[:error] = "You cannot search with an empty string." if params['commit']
    else
      @results = get_results(params['categories'])

    end
  end

  def dissertations 
    session['search'] = params
    session['search']['s.q'] = params['q'] if params['q']
    params['categories'] = ['catalog_dissertations', 'articles_dissertations', 'ac_dissertations']

    @results = {}
    if params['q'].to_s.strip.empty? 
      flash[:error] = "You cannot search with an empty string." if params['commit']
    else
      @results = get_results(params['categories'])

    end
  end

  def ebooks
    session['search'] = params
    session['search']['s.q'] = params['q'] if params['q']
    params['categories'] = ['catalog_ebooks', 'ebooks']

    @results = {}
    if params['q'].to_s.strip.empty? 
      flash[:error] = "You cannot search with an empty string." if params['commit']
    else
      @results = get_results(params['categories'])

    end
  end

  private

  def get_results(categories)
    @result_hash = {}
    categories.listify.each do |category|
      begin
        results = case category
                  when 'articles_dissertations'
                    summon = SerialSolutions::SummonAPI.new('category' => 'dissertations', 'new_search' => true,  's.q' => params[:q])

                    {
                      :docs => summon.search,
                      :count => summon.search.record_count.to_i, 
                      :url => articles_search_path(summon.search.query.to_hash)
                    }
                  when 'articles'
                    summon = SerialSolutions::SummonAPI.new('category' => 'articles', 'new_search' => true, 's.q' => params[:q], 's.ps' => 10)

                    {
                      :docs => summon.search,
                      :count => summon.search.record_count.to_i, 
                      :url => articles_search_path(summon.search.query.to_hash)
                    }
                  when 'articles_newspapers'
                    summon = SerialSolutions::SummonAPI.new('category' => 'newspapers', 'new_search' => true, 's.q' => params[:q], 's.ps' => 10)

                    {
                      :docs => summon.search,
                      :count => summon.search.record_count.to_i, 
                      :url => articles_search_path(summon.search.query.to_hash)
                    }
                  when 'ebooks'
                    summon = SerialSolutions::SummonAPI.new('category' => 'ebooks', 'new_search' => true, 's.q' => params[:q], 's.ps' => 10)
                    {
                      :docs => summon.search,
                      :count => summon.search.record_count.to_i,
                      :url => articles_search_path(summon.search.query.to_hash)
                    }
                  when 'catalog_ebooks'
                    configure_search('catalog')
                    params[:per_page] = 15
                    params[:f] = {'format' => ['Book', 'Online']}
                  
                    solr_response, solr_results =  get_and_debug_search_results
                    look_up_clio_holdings(solr_results)
                    {
                      :docs => solr_results,
                      :count => solr_response['response']['numFound'].to_i,
                      :url => url_for(:controller => 'catalog', :action => 'index', :q => params['q'], :f => {'format' => ['Book', 'Online']})
                    }
                  when 'catalog_databases'

                    configure_search('catalog')
                    params[:per_page] = 15
                    params[:f] = {'source_facet' => ['database']}
                    solr_response, solr_results =  get_and_debug_search_results
                    look_up_clio_holdings(solr_results)
                    {
                      :docs => solr_results,
                      :count => solr_response['response']['numFound'].to_i,
                      :url => url_for(:controller => 'catalog', :action => 'index', :q => params['q'], :f => {'source_facet' => ['database']})
                    }
                  when 'catalog_ejournals'

                    configure_search('catalog')
                    params[:per_page] = 15
                    params[:f] = {'source_facet' => ['ejournal']}
                    solr_response, solr_results =  get_and_debug_search_results
                    look_up_clio_holdings(solr_results)
                    {
                      :docs => solr_results,
                      :count => solr_response['response']['numFound'].to_i,
                      :url => url_for(:controller => 'catalog', :action => 'index', :q => params['q'], :f => {'source_facet' => ['ejournal']})
                    }
                  when 'catalog_dissertations'

                    configure_search('catalog')
                    params[:per_page] = 15
                    params[:f] = {'format' => ['Thesis']}
                    solr_response, solr_results =  get_and_debug_search_results
                    look_up_clio_holdings(solr_results)
                    {
                      :docs => solr_results,
                      :count => solr_response['response']['numFound'].to_i,
                      :url => url_for(:controller => 'catalog', :action => 'index', :q => params['q'], :f => {'format' => ['Thesis']})
                    }
                  when 'catalog'
                    configure_search('catalog')
                    params[:per_page] = 15
                    solr_response, solr_results =  get_and_debug_search_results
                    look_up_clio_holdings(solr_results)
                    {
                      :docs => solr_results,
                      :count => solr_response['response']['numFound'].to_i,
                      :url => url_for(:controller => 'catalog', :action => 'index', :q => params['q'])
                    }
                  when 'academic_commons'
                    configure_search('academic_commons')
                    params[:per_page] = 15

                    solr_response, solr_results =  get_and_debug_search_results
                    {
                      :docs => solr_results,
                      :count => solr_response['response']['numFound'].to_i,
                      :url => academic_commons_index_path(:q => params['q'])
                    }
                  when 'ac_dissertations'
                    configure_search('academic_commons')
                    params[:per_page] = 3
                    params[:genre_facet] = ['Dissertations']
                    params[:f] = {'genre_facet' => ['Dissertations']}
                    solr_acd_response, solr_acd_results =  get_and_debug_search_results(params)
                    {
                      :docs => solr_acd_results,
                      :count => solr_acd_response['response']['numFound'].to_i,
                      :url => academic_commons_index_path(:q => params['q'], :f => {'genre_facet' => ['Dissertations']})
                      
                    }
                  when 'lweb'
                    @search = LibraryWeb::Api.new('q' => params['q'])
                    {
                      :docs => @search.docs,
                      :count => @search.count, 
                      :url => library_web_index_path(:q => params['q'])
                    }

                  end
      rescue Exception => e
        results = { :error => true, :message => e.message, :docs => [] }
    
      end

      results.merge(:category => category)
      @result_hash[category] = results
    end

    @result_hash
  end


  def search_url_for(category, params)
    case category
    when 'articles'
      articles_search_path('s.q' => params['q'], :new_search => 'articles')
    when 'ebooks'
      articles_search_path('s.q' => params['q'], :new_search => 'ebooks')
    when 'catalog'
      url_for(:controller => 'catalog', :action => 'index', :q => params['q'])
    when 'catalog_ebooks'
      url_for(:controller => 'catalog', :action => 'index', :q => params['q'], :f => {'format' => ['Book', 'Online']})
    when 'academic_commons'
      academic_commons_index_path(:q => params['q'])
    when 'lweb'
      'http://search.columbia.edu/search?site=CUL_LibraryWeb&sitesearch=&as_dt=i&client=cul_libraryweb&proxystylesheet=cul_libraryweb&output=xml_no_dtd&ie=UTF-8&oe=UTF-8&filter=0&sort=date%3AD%3AL%3Adl&num=20&x=0&y=0&q=' +  CGI::escape(params[:q])
    when 'lweb_xml'
      'http://search.columbia.edu/search?site=CUL_LibraryWeb&sitesearch=&as_dt=i&client=cul_libraryweb&output=xml&ie=UTF-8&oe=UTF-8&filter=0&sort=date%3AD%3AL%3Adl&num=10&x=0&y=0&q=' +  CGI::escape(params[:q])
    end
  end

end
