namespace :init do
  desc 'This task is called by the Heroku cron add-on'
  task seed_prizes: :environment do
    Prize.destroy_all
    Prize.create(title: 'Cinemapolis', description: 'Movie Pass', count: 16)
    Prize.create(title: 'Ithaca Bakery', description: '$10 Gift Card', count: 8)
    Prize.create(title: 'Autumn Leaves', description: '$5 Gift Certificate', count: 4)
    Prize.create(title: 'Waffle Frolic', description: '$5 Gift Card', count: 4)
    Prize.create(title: 'Fall Creek Brass Band', description: 'Mad Fun CD', count: 1)
  end

  task add_prizes: :environment do
    p = Prize.create(title: 'Gimme Coffee', description: 'Free Drink Cards', count: 8)
    p.count.times do
      code = (0...8).map { rand(65..90).chr }.join
      PrizeWinner.create(code: code, prize_id: p.id)
    end
  end

  task set_codes: :environment do
    Prize.all.each do |p|
      p.count.times do
        code = (0...8).map { rand(65..90).chr }.join
        PrizeWinner.create(code: code, prize_id: p.id)
      end
    end
  end

  task set_regions: :environment do
    Region.create(name: 'Finger Lakes East', counties: 'Tompkins, Schuyler, Chemung, Steuben, Seneca', zipcodes: [])
    Region.create(name: 'Finger Lakes West', counties: 'Yates, Ontario, Monroe, Livingston', zipcodes: [])
    Region.create(name: 'Central NY', counties: 'Cayuga, Cortland, Onondaga, Madison', zipcodes: [])
    Region.create(name: 'Southern Tier', counties: 'Tioga, Broome, Chenango, Delaware', zipcodes: [])

    Region.all.each do |region|
      zips = []
      text = File.open("lib/assets/zipcodes/#{region.name}.txt").read
      text.each_line do |line|
        zips << line.strip
      end
      region.update_attribute(:zipcodes, zips)
    end
  end

  task import_regions: :environment do
    Region.all.each do |r|
      r.update_attribute(:zipcodes, [])
    end
    Dir.foreach('lib/assets/zipcodes') do |filename|
      next if (filename == '.') || (filename == '..')

      county = filename.split('.')[0]
      zips = File.readlines('lib/assets/zipcodes/' + filename)
      zips.map! { |z| z.strip }
      puts county
      Region.create!(name: county, zipcodes: zips)
    end
  end

  task assign_content_to_regions: :environment do
    # OFFSETS
    regions = Region.all
    Offset.all.each do |offset|
      if offset.zipcode.nil?
        offset.update_attribute(:region, Region.find_by_name('Tompkins'))
      else
        assigned = false
        regions.each do |region|
          if region.zipcodes.include? offset.zipcode.to_s
            offset.update_attribute(:region, region)
            assigned = true
          end
        end
        offset.update_attribute(:region, Region.find_by_name('Tompkins')) unless assigned
      end
    end

    # PRIZES, TEAMS, INDIVIDUALS, AWARDEES
    Prize.all.each do |prize|
      prize.update_attribute(:region, Region.find_by_name('Tompkins'))
    end
    Team.all.each do |team|
      assigned = false
      founder = team.team_members.where.not(founder: nil).first
      if founder.present?

        offsets = Offset.where(email: founder.email)
        zip = nil
        offsets.each do |offset|
          next unless zip.nil?

          zip = offset.zipcode.to_s if offset.zipcode.present?
        end
        next unless zip.present?

        regions.each do |region|
          if region.zipcodes.include? zip
            team.update_attribute(:region, region)
            assigned = true
          end
        end
      end

      team.update_attribute(:region, Region.find_by_name('Tompkins')) unless assigned
    end
    Individual.all.each do |team|
      assigned = false
      offsets = Offset.where(email: team.email)
      zip = nil
      offsets.each do |offset|
        next unless zip.nil?

        zip = offset.zipcode.to_s if offset.zipcode.present?
      end
      next unless zip.present?

      regions.each do |region|
        if region.zipcodes.include? zip
          team.update_attribute(:region, region)
          assigned = true
        end
      end
      team.update_attribute(:region, Region.find_by_name('Tompkins')) unless assigned
    end
    Awardee.all.each do |prize|
      prize.update_attribute(:region, Region.find_by_name('Tompkins'))
    end

    # destroy old regions after reassignment
    Region.where.not(counties: nil).destroy_all
  end

  task assign_teams_to_regions: :environment do
    regions = Region.all
    Individual.all.each do |team|
      assigned = false
      offsets = Offset.where(email: team.email)
      zip = nil
      offsets.each do |offset|
        next unless zip.nil?

        zip = offset.zipcode.to_s if offset.zipcode.present?
      end
      next unless zip.present?

      regions.each do |region|
        if region.zipcodes.include? zip
          team.update_attribute(:region, region)
          assigned = true
        end
      end
      team.update_attribute(:region, Region.find_by_name('Tompkins')) unless assigned
    end
  end

  task reassign_offsets: :environment do
    regions = Region.all
    Team.all.each do |t|
      count = 0
      t.team_members.each do |tm|
        next if tm.email

        offsets = Offset.where(email: tm.email)
        offsets.each do |off|
          if off.created_at > (tm.created_at - 1.hour)
            off.update_attribute(:team, t)
            count += 1
          end
        end
      end
      t.update_attribute(:count, count)
    end
  end

  task set_stats: :environment do
    # Stat.create(:pounds=>'3472400' , :dollars => '33092', :awardees => '18')
    Stat.create(pounds: '1622300', dollars: '16223', awardees: '18')
  end

  task fix_stats: :environment do
    # as of 3/26/15, before first online offset
    # $16,223/20 = 811 * $20/ton --> 1,622,300
    Stat.destroy_all
    s = Stat.create(pounds: '1622300', dollars: '16223', awardees: '18')
    Offset.where(purchased: true).each do |o|
      s.increment!(:pounds, o.pounds)
      s.increment!(:dollars, o.cost)
    end
    puts s.inspect
  end

  task recalculate_race_data: :environment do
    teams = Team.all
    teams.each do |team|
      team.update_attributes(pounds: 0, count: 0)
    end
    teams = Individual.all
    teams.each do |team|
      team.update_attributes(pounds: 0, count: 0)
    end
    offsets = Offset.where(purchased: :true).where('created_at > ?', DateTime.parse('2016-09-01T21:00:00-06:00'))
    offsets.each do |o|
      player = TeamMember.where(email: o.email).first
      if player.present?
        team = player.team
        team.increment!(:count)
        team.increment!(:pounds, o.pounds)
        o.update_attribute(:team_id, team.id)
      else
        player = Individual.where(email: o.email).first
        if player.present?
          player.increment!(:count)
          player.increment!(:pounds, o.pounds)
          o.update_attribute(:individual_id, player.id)
        end
      end
    end
  end

  task set_pages: :environment do
    Page.delete_all
    Page.create(title: 'faq', slug: 'faq', body: '

      <div class="faq-nav">
        <a href="#FAQ1">What are carbon offsets?</a>
        <a href="#FAQ2">How does the Finger Lakes Climate Fund Work?</a>
        <a href="#FAQ3">What does offsetting one ton of carbon emissions mean in everyday terms?</a>
        <a href="#FAQ4">How are the projects chosen?</a>
        <a href="#FAQ5">What are the advantages of local carbon offset projects?</a>
        <a href="#FAQ6">Shouldn’t we reduce our emissions before buying carbon offsets?</a>
      </div>
      <p>
        <span class="subhead"><a name="FAQ1"></a>What are carbon offsets?
        </span>
        <br>
        Carbon offsets allow people to “cancel out” the carbon emissions associated with their lifestyles. The energy we use in our homes, the fuel we burn in our cars, and the pollution that comes from the airplanes we travel in all generate greenhouse gas emissions that contribute to climate change. By purchasing carbon offsets you are investing money in an energy efficiency project and helping to reduce carbon emissions.
      </p>
      <p>A carbon offset represents a reduction of one ton of carbon dioxide equivalent. This means that for every offset you purchase, one ton of carbon dioxide emissions will be reduced on your behalf from a local energy efficiency project.</p>
      <p>What sets the Finger Lakes Climate Fund apart from other organizations offering carbon offsets is that we focus on local projects in the Finger Lakes region, ensuring that your money goes to work here in our own community. Also, by focusing on making low to moderate income households more energy efficient, our offset projects contribute to our local economy and support local families that need help.</p>
      <p>
        <span class="subhead"><a name="FAQ2"></a>How does the Finger Lakes Climate Fund Work?
        </span>
        <br>
        You can donate to the Finger Lakes Climate Fund in order to offset the carbon emissions associated with your home energy use, vehicle travel, or airplane travel. The money you donate contributes to reducing carbon emissions through a local energy efficiency project that would not otherwise be possible, therefore offsetting, or cancelling out, your carbon emissions.
      </p>
      <p>Donations to the Finger Lakes Climate Fund are used for grants to pay for energy efficiency projects in low to moderate income households in the Finger Lakes region. These grants help pay for insulation, air sealing, energy efficient heating equipment, and other upgrades to reduce energy use and greenhouse gas emissions.</p>
      <p>The energy efficiency upgrades are carried out by Building Performance Institute accredited contractors. Using guidelines provided by the New York State Energy Research and Development Authority, the contractors follow a strict protocol for accurately estimating the energy savings that will result from the energy renovations. The energy saving estimates for the projects are also verified by a third party organization that makes sure the carbon reduction calculations are accurate. This ensures that your carbon offset donations are resulting in actual greenhouse gas emission reductions.</p>
      <p>Of course, the first step is to try to minimize your personal emissions first by using less energy at home, driving less, and traveling fewer miles by plane. For more information on reducing your personal greenhouse gas emissions please visit the Reduce Your Emissions webpage.</p>
      <p>
        <span class="subhead"><a name="FAQ3"></a>What does offsetting one ton of carbon emissions mean in everyday terms?
        </span>
        <br>
        Offsetting one ton of carbon emissions is equivalent to saving 102 gallons of gas, planting 23 trees, taking an average car off the road for two months, or powering an average home for one month. For more information on finding the equivalent of your carbon offset, visit the EPA’s online
        <a href="http://www.epa.gov/cleanrgy/energy-resources/calculator.html" target="_blank">Greenhouse Gas Equivalencies Calculator.</a>
      </p>
      <p>
        <span class="subhead"><a name="FAQ4"></a>How are the projects chosen?
        </span>
        <br>
        <a href="http://www.sustainabletompkins.org" target="_blank" title="Sustainable Finger Lakes">Sustainable Finger Lakes</a>
        has an advisory committee to assist with approving offset projects that are funded through the Finger Lakes Climate Fund. NYSERDA Certified Energy contractors in our area are periodically invited to submit proposals for modest income families they are working with where a grant from the Climate Fund would add significant value to the projects The projects are vetted by the advisory committee and are approved by the Sustainable Finger Lakes Board of Directors. The projects must result in actual carbon reductions greater than or equal to the amount of the grant. Our goals for the projects are to reduce carbon emissions, help local families who need assistance, and strengthen our local economy.
      </p>
      <p>
        <span class="subhead"><a name="FAQ5"></a>What are the advantages of local carbon offset projects?
        </span>
        <br>
        Local carbon offsets allow you to see the results of your purchase right here in our community. Local offsets also help support the local economy by generating work for energy efficiency businesses. The Finger Lakes Climate Fund’s unique focus on low to moderate income households also has the benefit of helping people in our community who really need it. Other carbon offset suppliers don’t offer these kinds of local benefits that you’ll find with the Finger Lakes Climate Fund.
      </p>

    ')
    Page.create(title: 'Reduce Your Emissions', slug: 'reduce-emissions', body: '
      <p>There are many ways to reduce your carbon emissions. Below are some suggestions for several actions you can take and a list of resources that provide helpful information about saving energy and reducing your emissions.</p>
      <h4>Reduce Your Home Emissions</h4>
      <div class="embed-container">
      <iframe allowfullscreen="" frameborder="0" height="352" mozallowfullscreen="" src="https://player.vimeo.com/video/54961331" webkitallowfullscreen="" width="640"></iframe>
      </div>
      <ul>
      <li>Choose wisely when grocery shopping or eating out.  A plant-based diet releases far fewer greenhouse emissions than a meat-based diet and you can make a big difference simply by eating meat less often.  The type of meat and how it is produced also makes a big difference, and you can learn some simple rules for guiding your diet choices.</li>
      <li>Participate in Home Performance with Energy Star: With this program a trained professional will evaluate your home in order to identify exactly what your house needs to become more energy efficient. They’ll make recommendations for energy improvements and provide you with an estimate of how much the work will cost and how much money you’ll save on your utility bills as a result of the work. This is an excellent way to reduce your greenhouse gas emissions, save money on your energy bills, and have a more comfortable house. There are even financial incentives available to help you pay for qualifying work.</li>
      <li>Purchase Energy Star Appliances: When you’re shopping for new appliances make sure you look for the Energy Star label. This ensures that the product meets certain energy efficiency standards.</li>
      <li>Turn down your thermostat: Use a programmable thermostat to lower your heat when you’re away from your house and while you’re sleeping. Also, try lowering the temperature a bit to see if you can have it slightly cooler in the winter.</li>
      <li>Eliminate vampire load: Many appliances use electricity even when they’re turned off. This vampire load, or phantom load, adds up to a significant amount of energy. To eliminate this wasted energy, unplug your electrical equipment or use power strips and turn them off when you’re not using them.</li>
      <li>Conserve electricity: Make sure to turn off your lights, computer, and other electrical equipment when not in use.</li>
      <li>And consider offsetting your home’s carbon footprint through the Finger Lakes Climate Fund and putting those funds to work helping a local family to make our region more energy efficient. Watch Miranda Phillips talk about offsetting her family’s carbon footprint.</li>
      </ul>
      <h4>Reduce Your Vehicle Emissions</h4>
      <div class="embed-container">
      <iframe allowfullscreen="" frameborder="0" height="352" mozallowfullscreen="" src="https://player.vimeo.com/video/54468069" webkitallowfullscreen="" width="640"></iframe>
      </div>
      <ul>
      <li>Buy a fuel efficient vehicle: When you’re in the market for a new automobile, make sure to compare the fuel economy of the vehicles. Buying a smaller car or a hybrid vehicle can considerably reduce your carbon emissions over the long term.</li>
      <li>Drive less often: Look for opportunities to walk, bike, take the bus, or carpool. When you do have to drive, combine trips so you can save an extra trip and plan out your routes efficiently to drive fewer miles.</li>
      <li>Drive to save fuel: Make sure to avoid excessive idling, speeding, and rapid acceleration and braking. Also make sure to check your tire pressure and maintain your vehicle regularly. These actions can significantly increase the fuel efficiency of your current vehicle.</li>
      <li>Or consider offsetting your vehicle emissions through the Finger Lakes Climate Fund and putting those funds to work locally to make our region more energy efficient. Watch Nate Shinagawa talk about offsetting his commute.</li>
      </ul>
      <h4>Reduce Your Airplane Travel Emissions</h4>
      <div class="embed-container">
      <iframe allowfullscreen="" frameborder="0" height="352" mozallowfullscreen="" src="https://player.vimeo.com/video/54468068" webkitallowfullscreen="" width="640"></iframe>
      </div>
      <ul>
      <li>Ride the bus, take a train, or carpool: If possible, take a little more time to get to your destination by using a bus line or train to travel. Driving a full, fuel efficient car can also be better than flying in terms of greenhouse gas emissions.</li>
      <li>Participate in webinars and online conferences: Look for opportunities to avoid the trip altogether by participating in web-based meetings and conferences when possible.</li>
      <li>And if you must travel, consider offsetting your carbon emissions through the Finger Lakes Climate Fund and putting those funds to work locally to make our region more energy efficient. This video shows how you can offset your carbon footprint right at the airport.</li>
      </ul>
    ')
    Page.create(title: 'About Us', slug: 'about-us', body: '
      <h5>Our Mission</h5>
      <p>The Finger Lakes Climate Fund works to promote energy efficiency projects in the Finger Lakes area while strengthening our regional economy and assisting local families in need.</p>
      <p>Carbon offset donations are used for grants to fund energy efficiency projects that would not otherwise be possible in low to moderate income households in the Finger Lakes region. These grants help pay for insulation, air sealing, energy efficient heating equipment, and other upgrades to reduce energy use and greenhouse gas emissions. The Finger Lakes Climate Fund is also investigating other cost-effective local carbon offset projects such as solar hot water, solar photovoltaic, biomass heating, and other renewable energy projects.</p>
      <p>The Finger Lakes Climate Fund is a way for people to support our community while offsetting their home, plane, or vehicle pollution.</p>
      <p>The Finger Lakes Climate Fund offers carbon offsets for individuals businesses, non-profits, academic institutions, and special events. For more information on purchasing carbon offsets for your organization or special event please contact us at info@sustainabletompkins.org or 607-272-1720.</p>
      <h5>Sponsors &amp; Partners</h5>
      <b>Program Administrator</b>
      <p>The Finger Lakes Climate Fund is a project of
      <a href="http://sustainabletompkins.org">Sustainable Finger Lakes </a>a sustainability focused non-profit organization based in Ithaca, NY. The Finger Lakes Climate Fund is administered by Sustainable Finger Lakes’ staff and directors. Social Ventures, Inc. serves as Sustainable Finger Lakes’ 501(c)3 non-profit sponsor.</p>
      <b>Sponsors</b>
      <p>We are grateful for the continuing support of the Finger Lakes Climate Fund from the Park Foundation. It was their generosity that made it possible for us to build the carbon offset calculator, launch the Climate Fund and make our first grant.</p>
      <p>We’d also like to thank Bruce Lane, the Lane Family Fund of the Community Foundation of Tompkins County, and Purity Ice Cream for their generous gifts and offsets to the Climate Fund for the past several years. In addition, a $4000 check from a Carrot Mob organized by the Ithaca College Collective Impact fund and Purity Ice Cream gave us the resources we need to continue to promote the Climate Fund, find new users and make it possible for us to make several additional grants going forward. here’s the link to the<a href="http://sustainabletompkins.org/st-events/purity-ice-cream-and-ics-net-impact-club-donate-4000-to-finger-lakes-climate-fund/"> news story…</a></p>
      <p>We’re also grateful to the Sustainable Newfield Fund for their extraordinary gift to increase our Climate Fund grants in their community. Started by one donor who wanted to help her fracktivist neighbors get off of fossil fuels, she set up a fund with the Community Foundation where neighbors and acquaintances can make their offsets and direct the grants to other neighbors through the Finger Lakes Climate Fund. (
      <a href="http://sustainabletompkins.org/st-events/new-grant-fund-for-newfield-residents-announced/"> here’s the press release for this one</a>)</p>
      <h5>Partners</h5>
      <p>You can partner with the Finger Lakes Climate Fund as did the the Temple Beth El Green Team who have committed to raise one Climate Fund grant ($2000) from offsets from their Congregation; Center for A New American Dream Board–whose members offset their travel to their board retreat in California with the Finger Lakes Climate Fund; Tompkins County Chamber of Commerce Travel program who encourage all of the travelers in this program to offset their trips using the Climate Fund; the Congregation of Tikkun V’or who adopted the Finger Lakes Climate Fund as a Hannukah project and the upcoming Upstate NY Quaker Conference who have chosen the Finger Lakes Climate Fund to offset their car travel to their annual meeting.</p>
      <h5>Media Center</h5>
      Local Carbon Fund Supported by Cornell Conference
      Lansing Star – May 26, 2011
      <hr>
      Energy security and climate protection are interwoven global issues with highly local solutions according to local nonprofit Sustainable Finger Lakes.
      <a href="http://sustainabletompkins.org/st-events/purity-ice-cream-and-ics-net-impact-club-donate-4000-to-finger-lakes-climate-fund/">Read More</a>
      <hr>
      Partnerships drive Power of Climate Initiative
      Press Connects – May 5, 2011
      by Gary Stewart
      Finger Lakes Climate Fund noted as key partner in Tompkins County Climate Protection Initiative.
      <a href="http://www.pressconnects.com/article/20110506/VIEWPOINTS02/105060303/Partnerships-drive-power-climate-initiative/">Read More</a>
      <hr>
      Gay Nicholson gives a radio interview about launching
      the Finger Lakes Climate Fund
      <br>
      <a href="http://fingerlakesclimatefund.org/wp-content/uploads/2010/02/GN-Interview-2-9-10.mp3">listen to the audio</a>
      <hr>
      Tompkins urges travelers to go ‘green’
      Program rewards residents for cutting carbon emissions
      <a href="http://sustainabletompkins.org/st-in-news/sustainable-tompkins-urges-travelers-to-go-green/">Read More</a>
      <hr>
      Climate Fund Launched
      Tompkins Weekly – May 3, 2010
      By Kitty Gifford
      <hr>
      Businesses, organizations, schools and individuals are able to offset their carbon emissions by purchasing carbon offsets from the newly created Finger Lakes Climate Fund.
      <a href="http://sustainabletompkins.org/signs-of-sustainability/tompkins-weekly-column/climate-fund-launched/">Read More</a>
    ')

    Page.create(title: 'How Offsets Help Others', slug: 'portfolio', body: '
      <p>The Finger Lakes Climate Fund will initially fund residential energy efficiency projects for low to moderate income households in the Finger Lakes region. The fund will help pay for insulation, air sealing, energy efficient heating equipment, and other upgrades to reduce energy use and greenhouse gas emissions. The energy efficiency upgrades are carried out by Building Performance Institute accredited contractors using guidelines provided by the New York State Energy Research and Development Authority. These home energy efficiency projects reduce greenhouse gas emissions, support low income families, and help stimulate our local economy.</p>
      <h4>Project Verification Process</h4>
      <p>Verification ensures that carbon offset projects accurately calculate the amount of emissions that will be reduced as a result of the project. Through the Home Performance with Energy Star program, the residential energy efficiency projects follow industry best practices for estimating energy savings. Using guidelines provided by the New York State Energy Research and Development Authority (NYSERDA), the contractors follow a strict protocol for accurately predicting the long-term energy savings that will result from the home energy improvements. The energy saving estimates for the projects are also verified by a third party organization that makes sure the energy saving calculations are accurate. The Conservation Services Group partners with NYSERDA to review all energy saving calculations made by contractors to ensure that the calculations are accurate. This process ensures that your carbon offset donations are resulting in actual greenhouse gas emission reductions.</p>
      <h4>Profiles</h4>
      <p>We are proud to present these profiles of the home owners that have benefited from Finger Lakes Climate Fund grants. Thanks to the many donors to the Fund, these local families will be less vulnerable to rising fossil fuel prices and better positioned to remain stable and secure property owners. Over the long term, everyone benefits – the donors, the homeowners, local energy contractors, and the community.</p>
    ')

    Page.create(title: 'Business And Event Offsets', slug: 'business-event-offsets', body: '
      <p>The Finger Lakes Climate Fund also offers carbon offsets for businesses, non-profits, academic institutions, and special events. For more information on purchasing carbon offsets for your organization or special event please contact us at info@sustainabletompkins.org or 607-272-1720.</p>
      <h4>A few examples...</h4>
    ')
  end

  task fix_st_data: :environment do
    @offsets = Offset.where(team_id: 1, name: nil, email: nil)
    @offsets.each do |o|
      o.team_id = 0
      o.name = 'Manually Added'
      o.save
    end
    @offsets = Offset.where(name: 'Astrid Jirka', purchased: :true)
    @offsets.each do |o|
      o.team_id = 0
      o.save
    end
  end

  task redo_team_data: :environment do
    @teams = Team.all
    @teams.each do |t|
      total = t.offsets.sum(:pounds)
      count = t.offsets.count
      t.pounds = total
      t.count = count
      t.members = t.team_members.count
      t.save
    end
  end

  task redo_awardee: :environment do
    Awardee.create(
      id: 5,
      name: 'The Buckholtz Home',
      bio: '<p>Max Buckholtz is a local up and coming composer with a busy schedule of teaching, composing, and performance.  His wife had purchased a ranch-style house in the Town of Ithaca about a decade ago, and they soon realized they had a difficult problem lurking below the house.  They heavy clay soil in the area was perpetually saturated and the moist environment in their crawlspace was rotting out the foundation, leaking tons of heat energy, and loading their indoor air with molds and mildew.  Max bravely took on much of the work himself, but the complexity of the project and ill health from hours in the crawlspace sent him to Snug Planet to get help with the project. </p> <p>The diagnosis was daunting because so much work was needed to rescue the situation, and the Buckholtz family lived on a modest income.  Snug Planet organized access to NYSERDA’s Assisted Home Performance Program and also suggested that Max apply to the Finger Lakes Climate Fund for assistance.  We calculated that the work being done under the house would result in carbon emissions reductions of about 88 tons, and we were delighted to send them our fifth grant award of $1, 751 to help cover the costs.</p><p>When we visited the worksite, Snug Planet’s staff was carefully cutting and fitting large sheets of insulation to build up a thick wall of protection under the entire floor of the house, as well as taking the time to insulate pipes and ductwork running through the crawlspace.  Max reports that the house is much more comfortable as winter gets underway, and both he and his older daughter are feeling much healthier now that they are breathing clean indoor air.  Kudos to the donors of the Climate Fund for helping make this possible, and to the dedicated and very hard-working crew at Snug Planet for tackling this difficult project.</p>',
      video_id: '86458762',
      img_url: '',
      award_amount: '1751',
      award_date: '',
      pounds_offset: '88'
    )
  end

  task seed_awardees: :environment do
    Awardee.destroy_all
    Awardee.create(
      name: 'The Ellis Home',
      bio: '<p>Our first grant award from the Finger Lakes Climate Fund went to the Ellis Family in December 2010. Michael, Sherri, and their daughter, Emily, love their home in the woods, but their wood-burning stove was making Sherri’s allergies worse and it was hard to stay warm because of the drafts and lack of insulation. Michael’s schoolteacher salary needed some assistance in order to make the recommended energy improvements, so their contractor, Tompkins Community Action, suggested they apply for a local carbon offset grant from Sustainable Finger Lakes.</p> <p>The work scope for the project was estimated to reduce 50.4 tons of CO2 emissions over 20 years by installing an efficient wood pellet stove, insulating the attic, and sealing a variety of leaks in the house. After review by our grant-making committee of Ian Shapiro, Mark Pierce, Kathy Schlather, and Gay Nicholson, and approval by the Board of Directors, we were happy to award the first grant of $1008 to the Ellis Family.</p>',
      video_id: '54465948',
      img_url: '',
      award_amount: '1008',
      award_date: '',
      pounds_offset: '50.4'
    )

    Awardee.create(
      name: 'The Rosentel Home',
      bio: '<p>Our second grant was made to Jill Rosentel of Lansing in February 2011. Jill is a real estate agent and a first-time home buyer. Even though she was really excited to own her first home, the heating bills for her old and drafty house were daunting and the furnace had seen better days. ASI Energy evaluated the situation, and detailed a long list of improvements to reduce her heating bills. Jill needed help in order to go forward with the full project, and applied for a Finger Lakes Climate Fund grant.</p> <p>Jill’s house needed a new, high-efficiency furnace as well as a new water heater, major insulation work, and lots of air sealing. All of these improvements would remove about 130 tons of CO2 over their lifespan, so we gave Jill our maximum grant of $1500 towards her project. Jill is delighted by the improved comfort in her snug home and the cost savings – but she also recognizes the importance of lower carbon emissions and promised to spread the word to her fellow realtors.</p>',
      video_id: '54464346',
      img_url: '',
      award_amount: '1500',
      award_date: '',
      pounds_offset: '130'
    )
    Awardee.create(
      name: 'The Mazur Home',
      bio: '<p>The Mazur Family of Enfield received our third grant of $2,000 in May 2012. Beth and her two daughters loved the green vistas and rural charm of their new place, but like so many of us they discovered that the house itself was poorly designed in terms of energy and moisture management. Then, to make matters worse, the old furnace ended its life with a sooty fire in its basement chamber.</p> <p>The folks at Snug Planet did a thorough energy analysis of the house, and proposed a work scope involving major insulation and air sealing, a high efficiency boiler and water heater, and ventilating fans to address mildew and rot problems. The good news was that the Mazurs qualified for a $5,000 grant from NYSERDA for the work; but it was still going to be a big investment for a single mom to handle.</p><p>Beth wasn’t sure what to do, but the Snug Planet team helped her apply for additional help from the Finger Lakes Climate Fund. The project offset an estimated 100.4 tons of carbon dioxide, qualifying the Mazurs for our new maximum award of $2,000 to cover 100 tons of emissions. Thanks to the generous donors to the Fund, the Mazurs can relax and enjoy their home in all four seasons.</p>',
      video_id: '54465966',
      img_url: '',
      award_amount: '2000',
      award_date: '',
      pounds_offset: '200'
    )
    Awardee.create(
      name: 'The Thompson Home',
      bio: '<p>Deborah Thompson’s historic home on Marshall Street in the Fall Creek neighborhood of Ithaca received a thorough energy makeover from Snug Planet in June 2013.  Deb received the fourth grant from the Finger Lakes Climate Fund — our first in the city and our first for a senior citizen.   Snug Planet estimated that the improvements they made would eliminate about 54 tons of carbon dioxide emissions, which translated into a grant of $1,076 toward the total cost of the project.</p> <p>The blower door test had revealed that this lovely old home was exceptionally leaky for its size.  Insulation in the attic and side walls was scant and uneven, and the basement had all sorts of moisture problems. Over the course of several days, the “Snug” team did extensive work in insulating and sealing leaks in the attic, and addressed moisture problems, air leaks, and lack of insulation in the basement.</p><p>Deb Thompson is a well-known and beloved local community organizer and activist.  Her life has been lived by the values that guide the donors to the Climate Fund, and thus everyone involved in this project has been extra pleased to see Deb get a “little help from her friends” after so many years of being there to help others.   When we visited with Deb in her living room surrounded by the rich gleam of old chestnut woodwork, we imagined her safe and warm during next winter’s storms — thanks to the good people willing to take responsibility for protecting the climate.</p>',
      video_id: '',
      img_url: '',
      award_amount: '1076',
      award_date: '',
      pounds_offset: '54'
    )
    Awardee.create(
      name: 'The Buckholtz Home',
      bio: '<p>Max Buckholtz is a local up and coming composer with a busy schedule of teaching, composing, and performance.  His wife had purchased a ranch-style house in the Town of Ithaca about a decade ago, and they soon realized they had a difficult problem lurking below the house.  They heavy clay soil in the area was perpetually saturated and the moist environment in their crawlspace was rotting out the foundation, leaking tons of heat energy, and loading their indoor air with molds and mildew.  Max bravely took on much of the work himself, but the complexity of the project and ill health from hours in the crawlspace sent him to Snug Planet to get help with the project. </p> <p>The diagnosis was daunting because so much work was needed to rescue the situation, and the Buckholtz family lived on a modest income.  Snug Planet organized access to NYSERDA’s Assisted Home Performance Program and also suggested that Max apply to the Finger Lakes Climate Fund for assistance.  We calculated that the work being done under the house would result in carbon emissions reductions of about 88 tons, and we were delighted to send them our fifth grant award of $1, 751 to help cover the costs.</p><p>When we visited the worksite, Snug Planet’s staff was carefully cutting and fitting large sheets of insulation to build up a thick wall of protection under the entire floor of the house, as well as taking the time to insulate pipes and ductwork running through the crawlspace.  Max reports that the house is much more comfortable as winter gets underway, and both he and his older daughter are feeling much healthier now that they are breathing clean indoor air.  Kudos to the donors of the Climate Fund for helping make this possible, and to the dedicated and very hard-working crew at Snug Planet for tackling this difficult project.</p>',
      video_id: '86458762',
      img_url: '',
      award_amount: '1751',
      award_date: '',
      pounds_offset: '88'
    )
    Awardee.create(
      name: 'Second Wind Cottages',
      bio: '<p>Sometimes there are acts of generosity that are so inspiring they develop their own force field – drawing in others to amplify the original intention of making the world just a little better.&nbsp; The story of the seventh Climate Fund&nbsp;grant of $3,457 to the&nbsp;<a href="http://secondwindcottages.org/">Second Wind</a>&nbsp;cottages in Newfield is about the intersection of&nbsp;<em>two</em>&nbsp;such force fields.</p><p>In the summer of 2013, an anonymous donor approached Sustainable Finger Lakes with the idea of creating a Sustainable Newfield fund where people concerned about climate disruption could donate money to help lower-income residents in Newfield make their homes more efficient and less dependent on fossil fuel.&nbsp; Other donors have since joined in to help with this mission of slowing climate impacts by helping those least able to afford rising energy bills.</p><p>Their generosity intersected with that of the&nbsp;<a href="http://www.communityfaithpartners.org/">Community Faith Partners</a>&nbsp;when one of their members approached us about the possibility of applying for a climate fund grant to help pay for the insulation of six cottages they are building on donated land in Newfield. &nbsp;The cottages are to house homeless men, and make up the new Second Wind project – – the brainchild of Carmen Guidi, a local business owner whose faith led him to devote himself to&nbsp;healing the wound of homelessness by providing homes to those living in the “Jungle” near Ithaca.&nbsp; Carmen’s generosity and vision quickly drew in others from area churches and a beautiful and expanding circle of generosity has been growing ever since.&nbsp; (Readers can enjoy the full history of the project by visiting SecondWindCottages.org.)</p><p><a href="http://www.snugplanet.com/">Snug Planet</a>, one of our area’s leading green businesses, played a key role in this web of generosity.&nbsp; Our $3457 carbon offset grant was enough to pay for most of the insulation materials for the six cottages at Second Wind, but Snug Planet stepped up to donate the rest of the materials and to provide their skilled workforce to supervise the insulating and air&nbsp;sealing process.</p>',
      video_id: '',
      img_url: '',
      award_amount: '3457',
      award_date: '',
      pounds_offset: ''
    )
    Awardee.create(
      name: 'Cayuga Pure Organics',
      bio: '<p>Our eighth carbon offset grant is our first made to a local business.&nbsp; Late last spring, a dreadful fire destroyed the barn at Cayuga Pure Organics (CPO) in Brooktondale along with all the equipment they used for cleaning and packaging organic dry beans and grains grown at their farm and by other local farmers. &nbsp;As the only major supplier of organic beans in the region, CPO had become a key player in efforts to rebuild a secure local food system.&nbsp; Facing bankruptcy, the company launched a fundraising campaign and its customers, fans, and dozens of local food advocates responded with more than $87,000 in donations to help them rebuild.</p><p><a href="http://sustainabletompkins.org/">Sustainable Finger Lakes</a>, got involved when&nbsp;<a href="http://snugplanet.com/">Snug Planet</a>, the energy contractor for the building, realized they might be able to eliminate the need for a fossil fuel heating system if they could qualify for a grant from the Finger Lakes Climate Fund to help pay for the insulation upgrades. &nbsp;By creating a passive, super-insulated processing facility, the beanery will be able to stay within its required temperature range without supplemental heating or cooling.</p><p>The additional insulation will prevent 158 tons of carbon dioxide emissions over the next 30 years, which qualified CPO for the maximum Climate Fund grant of $2,500.&nbsp; This funding was made possible by a generous gift from an anonymous donor whose concern about climate change inspired him to offset several years of carbon emissions through the Finger Lakes Climate Fund.</p><p>It’s been a challenging year for the CPO team, but thanks to generous support from the community, the jobs of the young farmers have been saved along with this important component of a healthy local food supply.&nbsp; All this – plus a lighter carbon footprint in the years ahead.</p>',
      video_id: '',
      img_url: '',
      award_amount: '2500',
      award_date: '',
      pounds_offset: '158'
    )

    Awardee.create(
      name: 'The Copman Home',
      bio: '<p>When Linda Copman and her three daughters moved to Ithaca from their long-time home in Hawaii, they were completely unfamiliar with the realities of heating and cooling a home through four seasons. In their solar-powered island home, temperature control was simple – open a window if you’re warm and close it if you’re cold. Thus, when they fell in love with their pretty historic home in the Town of Ithaca, they didn’t know that they should ask to see the utility bills before purchase. <a href="https://vimeo.com/99507309" target="_blank">Watch the Copmans tell their story.</a></p><p>Their first heating bill during our recent long, cold winter filled Linda with dismay, but she immediately went to work researching her options and finding professional advice through the good folks at Snug Planet. They conducted an energy assessment and found that the house was basically uninsulated; but even worse was the leaking ductwork and grossly inefficient old boiler (you know you’re wasting fuel when your basement is uncomfortably hot while the rest of the house is freezing!).</p><p>The Copmans could not afford to do more than a boiler replacement, and even with a 50% NYSERDA matching grant, they were hard pressed to both pay their heating bills and come up with their half of the boiler costs. They were perfect candidates for a grant from the Finger Lakes Climate Fund, so Snug Planet helped them apply for assistance. Because of the extremely inefficient situation, just the one step of replacing the boiler was going to eliminate 118 tons of carbon dioxide, qualifying the Copmans for the ninth FLCF grant with an award of $2,361.</p><p>Linda and her daughters will be able to view the approach of next winter with much more equanimity. There’s still a long way to go to bring their home into the modern era of energy efficiency, but their utility bills should be far less ruinous now thanks to the generosity of the donors to the FLCF. The Copmans share a joyful and gracious approach to life, even in the face of adversity, and their sincere “aloha” of thanks should make all of our donors proud to participate.</p>',
      video_id: '99507309',
      img_url: '',
      award_amount: '2361',
      award_date: '',
      pounds_offset: '118'
    )
    Awardee.create(
      name: 'The Yantorno Home',
      bio: '<p>Runaway boiler!&nbsp; It’s a good thing David Yantorno was working at home the day he first turned on the heat last fall.&nbsp; When the house grew hot and the pipes started banging, he ventured into the basement and discovered that his 1947 vintage boiler was running out of control.&nbsp; After finding the boiler’s kill switch and letting things cool back down, David knew it was time to get professional help on their historic home’s energy systems. <a href="https://vimeo.com/100650108" target="_blank">Watch the Yantornos tell their story.</a></p><p>Angela and David Yantorno were delighted when they purchased their house on a quiet street in Ithaca’s Fall Creek neighborhood – at last a place big enough for their blended family with four young children. &nbsp;They knew they needed to replace the old boiler, but had hoped it could wait until they could afford it.&nbsp; Unfortunately, the fire risk posed by the ancient unit meant they didn’t have that option anymore.</p><p>Will Graeper of Halco Energy let them know about the 50% matching grant from NYSERDA that they qualified for, but affording the other half was a challenge.&nbsp; Will’s boss told him about the Finger Lakes Climate Fund, and shortly thereafter the Yantornos got the help they needed with a grant of $1,667.&nbsp; This was the tenth award from the Climate Fund and represented a carbon offset of 83.3 tons.&nbsp; Now the Yantornos are ready for their next Ithaca winter with a 98% efficient gas boiler whose variable speed pump will also reduce their electric bill.&nbsp; Thanks to the donors of the Finger Lakes Climate Fund, the Yantorno Family should be able to avoid further basement drama!</p>',
      video_id: '100650108',
      img_url: '',
      award_amount: '1667',
      award_date: '',
      pounds_offset: '83.3'
    )
    Awardee.create(
      name: 'The Fenner Home',
      bio: '<p>Santa came a little early in 2014 for young Kolleen Fenner and her family, thanks to donors to the Finger Lakes Climate Fund.</p><p>The Fenners’ 1920 bungalow home in Newfield suffered from lots of air leaks coming in from the crawlspace and garage door, making their 45-year old furnace labor to keep them warm.&nbsp; Tompkins Community Action let Daniel Fenner know about the financial assistance they could get through NYSERDA’s programs, but the critical difference came with the Climate Fund grant of $2,247. <a href="https://vimeo.com/116889849" target="_blank">Watch &nbsp;Daniel and Kolleen Fenner tell their story.</a></p><p>Their new high-efficiency propane furnace combined with steps to tighten up the house by sealing rim joists, insulating walls, wrapping pipes, and replacing the garage door will keep 112 tons of CO2 out of the atmosphere.&nbsp; Donations from the Sustainable Newfield Fund and other community members provided funds for the Fenner award.</p>',
      video_id: '116889849',
      img_url: '',
      award_amount: '2247',
      award_date: '',
      pounds_offset: '112'
    )
    Awardee.create(
      name: 'The Jensen Home',
      bio: '<p>Area homeowners are familiar with this story… &nbsp;Young couple buys old farmhouse while in graduate school. The place needs work, but the beautiful landscapes of the Town of Caroline seem like a wonderful place to raise a family. Then&nbsp;a few bitter winters reveal just how inadequate the insulation really is. <a href="https://vimeo.com/143662510" target="_blank">Watch the Jensens tell their story.</a></p><p>For the Jensens, the insulation in their 1860 home wasn’t just inadequate – it was missing! An energy audit found 8″ of empty airspace between the walls and the siding. &nbsp;No wonder there was frost every day in one corner of their dining room. With two small children in the house now, they were suffering from the high electricity costs of running space heaters in the children’s rooms and cold drafty rooms throughout the house.</p><p>Tompkins Community Action got in touch with the Finger Lakes Climate Fund on behalf of Nathan and Jen and little Cora and Silas. &nbsp;Shortly afterward, the Jensens received the twelfth climate fund grant of $2,283 to cover the 114 tons of emission reductions resulting from insulating the attic, floor, and walls and sealing up the rim joists in the basement as well.</p>',
      video_id: '143662510',
      img_url: '',
      award_amount: '2283',
      award_date: '',
      pounds_offset: '114'
    )
    Awardee.create(
      name: 'The Stanford Home',
      bio: '<p>Kim Stanford grew up in the beautiful valley that runs along Route 38 in the Town of Richford, Tioga County. The family property runs along the west side of the highway and up to the ridge top and an old orchard. The old farmhouse is charming and shaded by mature trees, but that just made the inside seem even more cold and drafty. When Kim returned to take over her parents’ home, she struggled to cover the high heating bills. And when her Cornell job became part-time and her furnace was red-tagged due to a cracked heat exchanger, she knew it was time to seek help. <a href="https://vimeo.com/143660743" target="_blank">Watch Kim Stanford talk about her home.</a></p><p>Snug Planet installed a high-efficiency furnace, and got to work on sealing the drafts and adding insulation to the attic and walls. &nbsp;All of this work should keep 114 tons of carbon dioxide out of our atmosphere. &nbsp;Kim’s grant of $2,286 is the thirteenth award from the Climate Fund, and our first grant outside of Tompkins County.</p><p>Kim&nbsp;expressed her appreciation to the donors of the Fund, and shares their values when it comes to protecting and cherishing our beautiful landscapes and ecosystems. She&nbsp;hopes to open her home as a B&amp;B sometime soon and share the beauty of this setting. Meanwhile, she will be enjoying much lower heating bills and greater comfort as she continues her family’s stewardship of this homestead.</p>',
      video_id: '',
      img_url: '',
      award_amount: '2286',
      award_date: '',
      pounds_offset: '114'
    )
    Awardee.create(
      name: 'The Wessel Home',
      bio: '<p>Peace is kept in the barnyard at Wildwood Farms by 5 white nanny goats supervising the dozens of ducks, chickens, guinea hens, and cats rescued by farmer Mary Wessel. After living in Norway for most of her adult life, Mary returned to the States to rejoin her family in upstate NY. She purchased a 6-acre homestead on the ridge above Queen Catherine marsh in Schuyler County and began the hard work of creating a sustainable refuge for humans and animals alike.</p><p>Like many rural dwellings, the farmhouse consisted of a series of additions tacked onto the original cabin with its massive stone hearth – none of them insulated or tightly constructed. When Mary’s elderly mother needed to move in with her, the utility bills skyrocketed as Mary tried to keep her mother warm with electric space heaters and DIY attempts to reduce the drafts. Finally she turned to <a href="http://www.snugplanet.com">Snug Planet</a> for help.  <a href="https://vimeo.com/178482171" target="_blank">Watch Mary Wessel talk about her farm.</a></p><p>The workscope from the energy assessment was huge. Over $20,000 in insulation and air sealing for the multiple attics and crawlspaces of the patchwork house was necessary, plus installation by Halco of two air source heat pumps in the kitchen and the mother’s bedroom. Due to their extremely limited income, almost half was covered by NYSERDA with the Climate Fund contributing another $2,226 for the 111 tons of carbon being offset just by tightening up the house.</p><p>Someday Mary hopes to add solar to meet the farm’s electric needs. She’s working to make Wildwood a pleasant retreat for those needing sanctuary and wanting to reconnect with the rhythms of a simpler life, in balance with what our landscape can sustain.</p>',
      video_id: '178482171',
      img_url: '',
      award_amount: '2226',
      award_date: '',
      pounds_offset: '111'
    )
    Awardee.create(
      name: 'The Dhondup Home',
      bio: '<p>Nyima Dhondup and Tenzin Tsokyi and their three children have lived in their c. 1910 home in Ithaca’s Northside for eight years. Fluctuating energy bills, a weak-in-the-knees water heater, asthma in their two youngest children from an ancient furnace, and uncomfortable drafts were a growing concern.</p><p>When Tenzin heard about the <a href="http://www.solartompkins.org/" target="_blank">Solar Tompkins HeatSmart Program</a> from a fellow Cornell librarian, she attended one of the community meetings and signed up for an energy audit with <a href="http://www.getzerodraft.com/?keyword=zerodraft&amp;gclid=Cj0KEQjw_eu8BRDC-YLHusmTmMEBEiQArW6c-MwX-F8UUVNpgsmu7joRg6AR0Ws-ikeKPQl9zDScjisaAu3q8P8HAQ" target="_blank">Zerodraft</a> to take advantage of the group discount with HeatSmart. <a href="https://vimeo.com/178471007" target="_blank">Watch Nyima and Tenzin talk about their home.</a></p><p>The list of needed improvements was long: attic, basement and laundry room airsealing and insulation, new kitchen windows, and a new furnace and water heater were required to protect the family’s health and lower their energy bills. Between the HeatSmart discount, NYSERDA grant and low-interest loan, and our Climate Fund grant of $1,375, all of the work was affordably done.</p><p>With this 15<sup>th</sup> award, we have offset another 69 tons of CO2 over the lifespan of these energy efficiency improvements.</p>',
      video_id: '178471007',
      img_url: '',
      award_amount: '1375',
      award_date: '',
      pounds_offset: '69'
    )
    Awardee.create(
      name: 'The Paw Home',
      bio: '<p>For Deteh and Hakhi Paw, it’s been a longer journey to home ownership than for most people. The Burmese natives spent ten years in a refugee camp in Thailand before finally reaching asylum in the U.S. in 2006 with their four children. In Ithaca, they learned a new language and adapted to a new climate and culture. A job at the Statler Hotel enabled them to finally purchase a 1970s split-level ranch in the Town of Ithaca. But to their surprise, this relatively new house was so poorly insulated and drafty that they were wearing their coats indoors during their first winter of 2014-2015. &nbsp;The worst offenders were the cantilevered parts of the house and the bedrooms over the garage. <a href="https://vimeo.com/178477403" target="_blank">Watch Deteh Paw talk about his family’s home.</a></p><p>A friend told Deteh about <a href="http://www.snugplanet.com/">Snug Planet</a>, whose energy audit of the home revealed a long list of needed insulation, air-sealing, and equipment replacement. It was far more than they could afford. But through cost sharing with NYSERDA programs and the Finger Lakes Climate Fund, the price was reduced to a level they could manage. Our grant for $1,224 helped offset 61 tons of carbon dioxide emissions from our community.</p><p>The relief and happiness&nbsp;the Paws feel&nbsp;at now having a safe and warm place of their own was clear during our visit. Comfort, warmth, security, and lower energy bills to boot!</p>',
      video_id: '178477403',
      img_url: '',
      award_amount: '1224',
      award_date: '',
      pounds_offset: '61'
    )
    Awardee.create(
      name: 'The Miner Home',
      bio: '<p>Adam Miner of Newfield probably didn’t expect to end up with a new job along with a new house. Adam is a first-time homebuyer who went through <a href="http://www.betterhousingtc.org/" target="_blank">Better Housing of Tompkins County</a>’s assistance program for modest-income buyers. He’d found a 1974 ranch house up in the forested hills south of Ithaca, but the folks at Better Housing had him contact <a href="http://www.tcactionweb.org/joomla/" target="_blank">Tompkins Community Action</a> for an energy assessment for it. As one might suspect of 1970s era construction, the insulation for the attic and crawlspace was practically absent, and all the appliances old and inefficient. TCA let him know about the Finger Lakes Climate Fund grants so that he would be able to start his journey of home ownership with a much more efficient and affordable structure. <a href="https://vimeo.com/178383311" target="_blank">Watch Adam Miner talk about his home.</a></p><p>The interesting conclusion to this story is that Adam is now working for TCA in the Energy Services Division. As he got acquainted with the team working on his house, his interest and aptitude won the attention of the crew leader who let Adam know there was an opening in his department. Now this young homeowner spends his spare time with DIY projects around his own place while his workdays are spent reducing carbon emissions in homes across the county.</p><p>With this 17<sup>th</sup> grant of $1,668 to eliminate 83 tons of CO2, we have offset 1604 tons of greenhouse gas emissions by investing grants worth $30,659.</p>',
      video_id: '178383311',
      img_url: '',
      award_amount: '1663',
      award_date: '',
      pounds_offset: '83'
    )
  end
end
