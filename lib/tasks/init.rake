namespace :init do
  desc "This task is called by the Heroku cron add-on"
  task :seed_prizes => :environment do
    Prize.destroy_all
    Prize.create(:title=>'Cinemapolis', :description => 'Movie Pass',:count=>16)
    Prize.create(:title=>'Ithaca Bakery', :description => '$10 Gift Card',:count=>8)
    Prize.create(:title=>'Autumn Leaves', :description => '$5 Gift Certificate',:count=>4)
    Prize.create(:title=>'Waffle Frolic', :description => '$5 Gift Card',:count=>4)
    Prize.create(:title=>'Fall Creek Brass Band', :description => 'Mad Fun CD',:count=>1)

  end

  task :add_prizes => :environment do

    p = Prize.create(:title=>'Gimme Coffee', :description => 'Free Drink Cards',:count=>8)
    p.count.times do
      code = (0...8).map { (65 + rand(26)).chr }.join
      PrizeWinner.create(:code=>code, :prize_id=>p.id)
    end
  end

  task :set_codes => :environment do
    Prize.all.each do |p|
      p.count.times do
        code = (0...8).map { (65 + rand(26)).chr }.join
        PrizeWinner.create(:code=>code, :prize_id=>p.id)
      end

    end
  end

  task :set_stats => :environment do
    Stat.create(:pounds=>'3472400' , :dollars => '33092', :awardees => '18')
  end

  task :recalculate_race_data => :environment do
    teams = Team.all
    teams.each do |team|
      team.update_attributes(:pounds=>0, :count=>0)
    end
    teams = Individual.all
    teams.each do |team|
      team.update_attributes(:pounds=>0, :count=>0)
    end
    offsets = Offset.where(:purchased=>:true).where('created_at > ?',DateTime.parse('2016-09-01T21:00:00-06:00'))
    offsets.each do |o|
      player = TeamMember.where(:email=>o.email).first
      if player.present?
        team = player.team
        team.increment!(:count)
        team.increment!(:pounds, o.pounds)
        o.update_attribute(:team_id, team.id)
      else
        player = Individual.where(:email=>o.email).first
        if player.present?
          player.increment!(:count)
          player.increment!(:pounds, o.pounds)
          o.update_attribute(:individual_id, player.id)
        end
      end
    end
  end

  task :seed_awardees => :environment do
    Awardee.destroy_all
    Awardee.create(
      :name=>'The Ellis Home',
      :bio=>'<p>Our first grant award from the Finger Lakes Climate Fund went to the Ellis Family in December 2010. Michael, Sherri, and their daughter, Emily, love their home in the woods, but their wood-burning stove was making Sherri’s allergies worse and it was hard to stay warm because of the drafts and lack of insulation. Michael’s schoolteacher salary needed some assistance in order to make the recommended energy improvements, so their contractor, Tompkins Community Action, suggested they apply for a local carbon offset grant from Sustainable Tompkins.</p> <p>The work scope for the project was estimated to reduce 50.4 tons of CO2 emissions over 20 years by installing an efficient wood pellet stove, insulating the attic, and sealing a variety of leaks in the house. After review by our grant-making committee of Ian Shapiro, Mark Pierce, Kathy Schlather, and Gay Nicholson, and approval by the Board of Directors, we were happy to award the first grant of $1008 to the Ellis Family.</p>',
      :video_id => '54465948',
      :img_url => '',
      :award_amount => '1008',
      :award_date => '',
      :pounds_offset => '50.4'
    )

    Awardee.create(
      :name=>'The Rosentel Home',
      :bio=>'<p>Our second grant was made to Jill Rosentel of Lansing in February 2011. Jill is a real estate agent and a first-time home buyer. Even though she was really excited to own her first home, the heating bills for her old and drafty house were daunting and the furnace had seen better days. ASI Energy evaluated the situation, and detailed a long list of improvements to reduce her heating bills. Jill needed help in order to go forward with the full project, and applied for a Finger Lakes Climate Fund grant.</p> <p>Jill’s house needed a new, high-efficiency furnace as well as a new water heater, major insulation work, and lots of air sealing. All of these improvements would remove about 130 tons of CO2 over their lifespan, so we gave Jill our maximum grant of $1500 towards her project. Jill is delighted by the improved comfort in her snug home and the cost savings – but she also recognizes the importance of lower carbon emissions and promised to spread the word to her fellow realtors.</p>',
      :video_id => '54464346',
      :img_url => '',
      :award_amount => '1500',
      :award_date => '',
      :pounds_offset => '130'
    )
    Awardee.create(
      :name=>'The Mazur Home',
      :bio=>'<p>The Mazur Family of Enfield received our third grant of $2,000 in May 2012. Beth and her two daughters loved the green vistas and rural charm of their new place, but like so many of us they discovered that the house itself was poorly designed in terms of energy and moisture management. Then, to make matters worse, the old furnace ended its life with a sooty fire in its basement chamber.</p> <p>The folks at Snug Planet did a thorough energy analysis of the house, and proposed a work scope involving major insulation and air sealing, a high efficiency boiler and water heater, and ventilating fans to address mildew and rot problems. The good news was that the Mazurs qualified for a $5,000 grant from NYSERDA for the work; but it was still going to be a big investment for a single mom to handle.</p><p>Beth wasn’t sure what to do, but the Snug Planet team helped her apply for additional help from the Finger Lakes Climate Fund. The project offset an estimated 100.4 tons of carbon dioxide, qualifying the Mazurs for our new maximum award of $2,000 to cover 100 tons of emissions. Thanks to the generous donors to the Fund, the Mazurs can relax and enjoy their home in all four seasons.</p>',
      :video_id => '54465966',
      :img_url => '',
      :award_amount => '2000',
      :award_date => '',
      :pounds_offset => '200'
    )
    Awardee.create(
      :name=>'The Thompson Home',
      :bio=>'<p>Deborah Thompson’s historic home on Marshall Street in the Fall Creek neighborhood of Ithaca received a thorough energy makeover from Snug Planet in June 2013.  Deb received the fourth grant from the Finger Lakes Climate Fund — our first in the city and our first for a senior citizen.   Snug Planet estimated that the improvements they made would eliminate about 54 tons of carbon dioxide emissions, which translated into a grant of $1,076 toward the total cost of the project.</p> <p>The blower door test had revealed that this lovely old home was exceptionally leaky for its size.  Insulation in the attic and side walls was scant and uneven, and the basement had all sorts of moisture problems. Over the course of several days, the “Snug” team did extensive work in insulating and sealing leaks in the attic, and addressed moisture problems, air leaks, and lack of insulation in the basement.</p><p>Deb Thompson is a well-known and beloved local community organizer and activist.  Her life has been lived by the values that guide the donors to the Climate Fund, and thus everyone involved in this project has been extra pleased to see Deb get a “little help from her friends” after so many years of being there to help others.   When we visited with Deb in her living room surrounded by the rich gleam of old chestnut woodwork, we imagined her safe and warm during next winter’s storms — thanks to the good people willing to take responsibility for protecting the climate.</p>',
      :video_id => '',
      :img_url => '',
      :award_amount => '1076',
      :award_date => '',
      :pounds_offset => '54'
    )
    Awardee.create(
      :name=>'The Buckholtz Home',
      :bio=>'<p>Max Buckholtz is a local up and coming composer with a busy schedule of teaching, composing, and performance.  His wife had purchased a ranch-style house in the Town of Ithaca about a decade ago, and they soon realized they had a difficult problem lurking below the house.  They heavy clay soil in the area was perpetually saturated and the moist environment in their crawlspace was rotting out the foundation, leaking tons of heat energy, and loading their indoor air with molds and mildew.  Max bravely took on much of the work himself, but the complexity of the project and ill health from hours in the crawlspace sent him to Snug Planet to get help with the project. </p> <p>The diagnosis was daunting because so much work was needed to rescue the situation, and the Buckholtz family lived on a modest income.  Snug Planet organized access to NYSERDA’s Assisted Home Performance Program and also suggested that Max apply to the Finger Lakes Climate Fund for assistance.  We calculated that the work being done under the house would result in carbon emissions reductions of about 88 tons, and we were delighted to send them our fifth grant award of $1, 751 to help cover the costs.</p><p>When we visited the worksite, Snug Planet’s staff was carefully cutting and fitting large sheets of insulation to build up a thick wall of protection under the entire floor of the house, as well as taking the time to insulate pipes and ductwork running through the crawlspace.  Max reports that the house is much more comfortable as winter gets underway, and both he and his older daughter are feeling much healthier now that they are breathing clean indoor air.  Kudos to the donors of the Climate Fund for helping make this possible, and to the dedicated and very hard-working crew at Snug Planet for tackling this difficult project.</p>',
      :video_id => '86458762',
      :img_url => '',
      :award_amount => '1751',
      :award_date => '',
      :pounds_offset => '88'
    )
    Awardee.create(
      :name=>'Second Wind Cottages',
      :bio=>'<p>Sometimes there are acts of generosity that are so inspiring they develop their own force field – drawing in others to amplify the original intention of making the world just a little better.&nbsp; The story of the seventh Climate Fund&nbsp;grant of $3,457 to the&nbsp;<a href="http://secondwindcottages.org/">Second Wind</a>&nbsp;cottages in Newfield is about the intersection of&nbsp;<em>two</em>&nbsp;such force fields.</p><p>In the summer of 2013, an anonymous donor approached Sustainable Tompkins with the idea of creating a Sustainable Newfield fund where people concerned about climate disruption could donate money to help lower-income residents in Newfield make their homes more efficient and less dependent on fossil fuel.&nbsp; Other donors have since joined in to help with this mission of slowing climate impacts by helping those least able to afford rising energy bills.</p><p>Their generosity intersected with that of the&nbsp;<a href="http://www.communityfaithpartners.org/">Community Faith Partners</a>&nbsp;when one of their members approached us about the possibility of applying for a climate fund grant to help pay for the insulation of six cottages they are building on donated land in Newfield. &nbsp;The cottages are to house homeless men, and make up the new Second Wind project – – the brainchild of Carmen Guidi, a local business owner whose faith led him to devote himself to&nbsp;healing the wound of homelessness by providing homes to those living in the “Jungle” near Ithaca.&nbsp; Carmen’s generosity and vision quickly drew in others from area churches and a beautiful and expanding circle of generosity has been growing ever since.&nbsp; (Readers can enjoy the full history of the project by visiting SecondWindCottages.org.)</p><p><a href="http://www.snugplanet.com/">Snug Planet</a>, one of our area’s leading green businesses, played a key role in this web of generosity.&nbsp; Our $3457 carbon offset grant was enough to pay for most of the insulation materials for the six cottages at Second Wind, but Snug Planet stepped up to donate the rest of the materials and to provide their skilled workforce to supervise the insulating and air&nbsp;sealing process.</p>',
      :video_id => '',
      :img_url => '',
      :award_amount => '3457',
      :award_date => '',
      :pounds_offset => ''
    )
    Awardee.create(
      :name=>'Cayuga Pure Organics',
      :bio=>'<p>Our eighth carbon offset grant is our first made to a local business.&nbsp; Late last spring, a dreadful fire destroyed the barn at Cayuga Pure Organics (CPO) in Brooktondale along with all the equipment they used for cleaning and packaging organic dry beans and grains grown at their farm and by other local farmers. &nbsp;As the only major supplier of organic beans in the region, CPO had become a key player in efforts to rebuild a secure local food system.&nbsp; Facing bankruptcy, the company launched a fundraising campaign and its customers, fans, and dozens of local food advocates responded with more than $87,000 in donations to help them rebuild.</p><p><a href="http://sustainabletompkins.org/">Sustainable Tompkins</a>, got involved when&nbsp;<a href="http://snugplanet.com/">Snug Planet</a>, the energy contractor for the building, realized they might be able to eliminate the need for a fossil fuel heating system if they could qualify for a grant from the Finger Lakes Climate Fund to help pay for the insulation upgrades. &nbsp;By creating a passive, super-insulated processing facility, the beanery will be able to stay within its required temperature range without supplemental heating or cooling.</p><p>The additional insulation will prevent 158 tons of carbon dioxide emissions over the next 30 years, which qualified CPO for the maximum Climate Fund grant of $2,500.&nbsp; This funding was made possible by a generous gift from an anonymous donor whose concern about climate change inspired him to offset several years of carbon emissions through the Finger Lakes Climate Fund.</p><p>It’s been a challenging year for the CPO team, but thanks to generous support from the community, the jobs of the young farmers have been saved along with this important component of a healthy local food supply.&nbsp; All this – plus a lighter carbon footprint in the years ahead.</p>',
      :video_id => '',
      :img_url => '',
      :award_amount => '2500',
      :award_date => '',
      :pounds_offset => '158'
    )

    Awardee.create(
      :name=>'The Copman Home',
      :bio=>'<p>When Linda Copman and her three daughters moved to Ithaca from their long-time home in Hawaii, they were completely unfamiliar with the realities of heating and cooling a home through four seasons. In their solar-powered island home, temperature control was simple – open a window if you’re warm and close it if you’re cold. Thus, when they fell in love with their pretty historic home in the Town of Ithaca, they didn’t know that they should ask to see the utility bills before purchase. <a href="https://vimeo.com/99507309" target="_blank">Watch the Copmans tell their story.</a></p><p>Their first heating bill during our recent long, cold winter filled Linda with dismay, but she immediately went to work researching her options and finding professional advice through the good folks at Snug Planet. They conducted an energy assessment and found that the house was basically uninsulated; but even worse was the leaking ductwork and grossly inefficient old boiler (you know you’re wasting fuel when your basement is uncomfortably hot while the rest of the house is freezing!).</p><p>The Copmans could not afford to do more than a boiler replacement, and even with a 50% NYSERDA matching grant, they were hard pressed to both pay their heating bills and come up with their half of the boiler costs. They were perfect candidates for a grant from the Finger Lakes Climate Fund, so Snug Planet helped them apply for assistance. Because of the extremely inefficient situation, just the one step of replacing the boiler was going to eliminate 118 tons of carbon dioxide, qualifying the Copmans for the ninth FLCF grant with an award of $2,361.</p><p>Linda and her daughters will be able to view the approach of next winter with much more equanimity. There’s still a long way to go to bring their home into the modern era of energy efficiency, but their utility bills should be far less ruinous now thanks to the generosity of the donors to the FLCF. The Copmans share a joyful and gracious approach to life, even in the face of adversity, and their sincere “aloha” of thanks should make all of our donors proud to participate.</p>',
      :video_id => '99507309',
      :img_url => '',
      :award_amount => '2361',
      :award_date => '',
      :pounds_offset => '118'
    )
    Awardee.create(
      :name=>'The Yantorno Home',
      :bio=>'<p>Runaway boiler!&nbsp; It’s a good thing David Yantorno was working at home the day he first turned on the heat last fall.&nbsp; When the house grew hot and the pipes started banging, he ventured into the basement and discovered that his 1947 vintage boiler was running out of control.&nbsp; After finding the boiler’s kill switch and letting things cool back down, David knew it was time to get professional help on their historic home’s energy systems. <a href="https://vimeo.com/100650108" target="_blank">Watch the Yantornos tell their story.</a></p><p>Angela and David Yantorno were delighted when they purchased their house on a quiet street in Ithaca’s Fall Creek neighborhood – at last a place big enough for their blended family with four young children. &nbsp;They knew they needed to replace the old boiler, but had hoped it could wait until they could afford it.&nbsp; Unfortunately, the fire risk posed by the ancient unit meant they didn’t have that option anymore.</p><p>Will Graeper of Halco Energy let them know about the 50% matching grant from NYSERDA that they qualified for, but affording the other half was a challenge.&nbsp; Will’s boss told him about the Finger Lakes Climate Fund, and shortly thereafter the Yantornos got the help they needed with a grant of $1,667.&nbsp; This was the tenth award from the Climate Fund and represented a carbon offset of 83.3 tons.&nbsp; Now the Yantornos are ready for their next Ithaca winter with a 98% efficient gas boiler whose variable speed pump will also reduce their electric bill.&nbsp; Thanks to the donors of the Finger Lakes Climate Fund, the Yantorno Family should be able to avoid further basement drama!</p>',
      :video_id => '100650108',
      :img_url => '',
      :award_amount => '1667',
      :award_date => '',
      :pounds_offset => '83.3'
    )
    Awardee.create(
      :name=>'The Fenner Home',
      :bio=>'<p>Santa came a little early in 2014 for young Kolleen Fenner and her family, thanks to donors to the Finger Lakes Climate Fund.</p><p>The Fenners’ 1920 bungalow home in Newfield suffered from lots of air leaks coming in from the crawlspace and garage door, making their 45-year old furnace labor to keep them warm.&nbsp; Tompkins Community Action let Daniel Fenner know about the financial assistance they could get through NYSERDA’s programs, but the critical difference came with the Climate Fund grant of $2,247. <a href="https://vimeo.com/116889849" target="_blank">Watch &nbsp;Daniel and Kolleen Fenner tell their story.</a></p><p>Their new high-efficiency propane furnace combined with steps to tighten up the house by sealing rim joists, insulating walls, wrapping pipes, and replacing the garage door will keep 112 tons of CO2 out of the atmosphere.&nbsp; Donations from the Sustainable Newfield Fund and other community members provided funds for the Fenner award.</p>',
      :video_id => '116889849',
      :img_url => '',
      :award_amount => '2247',
      :award_date => '',
      :pounds_offset => '112'
    )
    Awardee.create(
      :name=>'The Jensen Home',
      :bio=>'<p>Area homeowners are familiar with this story… &nbsp;Young couple buys old farmhouse while in graduate school. The place needs work, but the beautiful landscapes of the Town of Caroline seem like a wonderful place to raise a family. Then&nbsp;a few bitter winters reveal just how inadequate the insulation really is. <a href="https://vimeo.com/143662510" target="_blank">Watch the Jensens tell their story.</a></p><p>For the Jensens, the insulation in their 1860 home wasn’t just inadequate – it was missing! An energy audit found 8″ of empty airspace between the walls and the siding. &nbsp;No wonder there was frost every day in one corner of their dining room. With two small children in the house now, they were suffering from the high electricity costs of running space heaters in the children’s rooms and cold drafty rooms throughout the house.</p><p>Tompkins Community Action got in touch with the Finger Lakes Climate Fund on behalf of Nathan and Jen and little Cora and Silas. &nbsp;Shortly afterward, the Jensens received the twelfth climate fund grant of $2,283 to cover the 114 tons of emission reductions resulting from insulating the attic, floor, and walls and sealing up the rim joists in the basement as well.</p>',
      :video_id => '143662510',
      :img_url => '',
      :award_amount => '2283',
      :award_date => '',
      :pounds_offset => '114'
    )
    Awardee.create(
      :name=>'The Stanford Home',
      :bio=>'<p>Kim Stanford grew up in the beautiful valley that runs along Route 38 in the Town of Richford, Tioga County. The family property runs along the west side of the highway and up to the ridge top and an old orchard. The old farmhouse is charming and shaded by mature trees, but that just made the inside seem even more cold and drafty. When Kim returned to take over her parents’ home, she struggled to cover the high heating bills. And when her Cornell job became part-time and her furnace was red-tagged due to a cracked heat exchanger, she knew it was time to seek help. <a href="https://vimeo.com/143660743" target="_blank">Watch Kim Stanford talk about her home.</a></p><p>Snug Planet installed a high-efficiency furnace, and got to work on sealing the drafts and adding insulation to the attic and walls. &nbsp;All of this work should keep 114 tons of carbon dioxide out of our atmosphere. &nbsp;Kim’s grant of $2,286 is the thirteenth award from the Climate Fund, and our first grant outside of Tompkins County.</p><p>Kim&nbsp;expressed her appreciation to the donors of the Fund, and shares their values when it comes to protecting and cherishing our beautiful landscapes and ecosystems. She&nbsp;hopes to open her home as a B&amp;B sometime soon and share the beauty of this setting. Meanwhile, she will be enjoying much lower heating bills and greater comfort as she continues her family’s stewardship of this homestead.</p>',
      :video_id => '',
      :img_url => '',
      :award_amount => '2286',
      :award_date => '',
      :pounds_offset => '114'
    )
    Awardee.create(
      :name=>'The Wessel Home',
      :bio=>'<p>Peace is kept in the barnyard at Wildwood Farms by 5 white nanny goats supervising the dozens of ducks, chickens, guinea hens, and cats rescued by farmer Mary Wessel. After living in Norway for most of her adult life, Mary returned to the States to rejoin her family in upstate NY. She purchased a 6-acre homestead on the ridge above Queen Catherine marsh in Schuyler County and began the hard work of creating a sustainable refuge for humans and animals alike.</p><p>Like many rural dwellings, the farmhouse consisted of a series of additions tacked onto the original cabin with its massive stone hearth – none of them insulated or tightly constructed. When Mary’s elderly mother needed to move in with her, the utility bills skyrocketed as Mary tried to keep her mother warm with electric space heaters and DIY attempts to reduce the drafts. Finally she turned to <a href="http://www.snugplanet.com">Snug Planet</a> for help.  <a href="https://vimeo.com/178482171" target="_blank">Watch Mary Wessel talk about her farm.</a></p><p>The workscope from the energy assessment was huge. Over $20,000 in insulation and air sealing for the multiple attics and crawlspaces of the patchwork house was necessary, plus installation by Halco of two air source heat pumps in the kitchen and the mother’s bedroom. Due to their extremely limited income, almost half was covered by NYSERDA with the Climate Fund contributing another $2,226 for the 111 tons of carbon being offset just by tightening up the house.</p><p>Someday Mary hopes to add solar to meet the farm’s electric needs. She’s working to make Wildwood a pleasant retreat for those needing sanctuary and wanting to reconnect with the rhythms of a simpler life, in balance with what our landscape can sustain.</p>',
      :video_id => '178482171',
      :img_url => '',
      :award_amount => '2226',
      :award_date => '',
      :pounds_offset => '111'
    )
    Awardee.create(
      :name=>'The Dhondup Home',
      :bio=>'<p>Nyima Dhondup and Tenzin Tsokyi and their three children have lived in their c. 1910 home in Ithaca’s Northside for eight years. Fluctuating energy bills, a weak-in-the-knees water heater, asthma in their two youngest children from an ancient furnace, and uncomfortable drafts were a growing concern.</p><p>When Tenzin heard about the <a href="http://www.solartompkins.org/" target="_blank">Solar Tompkins HeatSmart Program</a> from a fellow Cornell librarian, she attended one of the community meetings and signed up for an energy audit with <a href="http://www.getzerodraft.com/?keyword=zerodraft&amp;gclid=Cj0KEQjw_eu8BRDC-YLHusmTmMEBEiQArW6c-MwX-F8UUVNpgsmu7joRg6AR0Ws-ikeKPQl9zDScjisaAu3q8P8HAQ" target="_blank">Zerodraft</a> to take advantage of the group discount with HeatSmart. <a href="https://vimeo.com/178471007" target="_blank">Watch Nyima and Tenzin talk about their home.</a></p><p>The list of needed improvements was long: attic, basement and laundry room airsealing and insulation, new kitchen windows, and a new furnace and water heater were required to protect the family’s health and lower their energy bills. Between the HeatSmart discount, NYSERDA grant and low-interest loan, and our Climate Fund grant of $1,375, all of the work was affordably done.</p><p>With this 15<sup>th</sup> award, we have offset another 69 tons of CO2 over the lifespan of these energy efficiency improvements.</p>',
      :video_id => '178471007',
      :img_url => '',
      :award_amount => '1375',
      :award_date => '',
      :pounds_offset => '69'
    )
    Awardee.create(
      :name=>'The Paw Home',
      :bio=>'<p>For Deteh and Hakhi Paw, it’s been a longer journey to home ownership than for most people. The Burmese natives spent ten years in a refugee camp in Thailand before finally reaching asylum in the U.S. in 2006 with their four children. In Ithaca, they learned a new language and adapted to a new climate and culture. A job at the Statler Hotel enabled them to finally purchase a 1970s split-level ranch in the Town of Ithaca. But to their surprise, this relatively new house was so poorly insulated and drafty that they were wearing their coats indoors during their first winter of 2014-2015. &nbsp;The worst offenders were the cantilevered parts of the house and the bedrooms over the garage. <a href="https://vimeo.com/178477403" target="_blank">Watch Deteh Paw talk about his family’s home.</a></p><p>A friend told Deteh about <a href="http://www.snugplanet.com/">Snug Planet</a>, whose energy audit of the home revealed a long list of needed insulation, air-sealing, and equipment replacement. It was far more than they could afford. But through cost sharing with NYSERDA programs and the Finger Lakes Climate Fund, the price was reduced to a level they could manage. Our grant for $1,224 helped offset 61 tons of carbon dioxide emissions from our community.</p><p>The relief and happiness&nbsp;the Paws feel&nbsp;at now having a safe and warm place of their own was clear during our visit. Comfort, warmth, security, and lower energy bills to boot!</p>',
      :video_id => '178477403',
      :img_url => '',
      :award_amount => '1224',
      :award_date => '',
      :pounds_offset => '61'
    )
    Awardee.create(
      :name=>'The Miner Home',
      :bio=>'<p>Adam Miner of Newfield probably didn’t expect to end up with a new job along with a new house. Adam is a first-time homebuyer who went through <a href="http://www.betterhousingtc.org/" target="_blank">Better Housing of Tompkins County</a>’s assistance program for modest-income buyers. He’d found a 1974 ranch house up in the forested hills south of Ithaca, but the folks at Better Housing had him contact <a href="http://www.tcactionweb.org/joomla/" target="_blank">Tompkins Community Action</a> for an energy assessment for it. As one might suspect of 1970s era construction, the insulation for the attic and crawlspace was practically absent, and all the appliances old and inefficient. TCA let him know about the Finger Lakes Climate Fund grants so that he would be able to start his journey of home ownership with a much more efficient and affordable structure. <a href="https://vimeo.com/178383311" target="_blank">Watch Adam Miner talk about his home.</a></p><p>The interesting conclusion to this story is that Adam is now working for TCA in the Energy Services Division. As he got acquainted with the team working on his house, his interest and aptitude won the attention of the crew leader who let Adam know there was an opening in his department. Now this young homeowner spends his spare time with DIY projects around his own place while his workdays are spent reducing carbon emissions in homes across the county.</p><p>With this 17<sup>th</sup> grant of $1,668 to eliminate 83 tons of CO2, we have offset 1604 tons of greenhouse gas emissions by investing grants worth $30,659.</p>',
      :video_id => '178383311',
      :img_url => '',
      :award_amount => '1663',
      :award_date => '',
      :pounds_offset => '83'
    )
  end
end