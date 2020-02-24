@@teams_file = "teams.csv"
@@ids_file = "ids.csv"
@@minimum_members = 3
@@maximum_members = 5

@ids_indexes = [2,4,6,8,10] # Columns in teams file which correspond to ids
@ids_map = {}
@teams_map = {}
@incomplete_teams = {}

def read_ids()
    # Assumes that the csv file is ids, name
    lines = File.readlines(@@ids_file)
    for line in lines do
        lines_split = line.split(",")
        @ids_map[lines_split[0].strip] = false
    end
end

def team_management(print, fill)

    read_ids()
    lines = File.readlines(@@teams_file)
    found_table = {}

    check_duplicate_students(true)

    # Check for correct team size
    for line in lines do
        fields = line.split(",")
        members = fields.select.with_index {|member, index| @ids_indexes.include? index}
        members = members.map {|member| member.strip}

        filtered_members = members.select {|member| (!member.nil? && member != "null")}

        # Assumes that the csv file has team name as first field
        if fill
            @teams_map[fields[0].strip] = filtered_members
        end

        if (filtered_members.length < @@minimum_members || filtered_members.length > @@maximum_members)
            @incomplete_teams[fields[0].strip] = true
        end

    end

    if print
        for k,v in @teams_map do
            puts("TEAM #{k} members #{v}")
        end
    end

end

def check_duplicate_students(print)
    lines = File.readlines(@@teams_file)

    found_table = {}
    duplicates_table = {}

    # Check for duplicates and missing students
    ids = @ids_map.keys
    for id in ids do
        found = false
        for line in lines do
            fields = line.split(",")

            for field in @ids_indexes do
                if fields[field].nil?
                    next
                end

                if(fields[field].strip == (id))
                    if !found
                        @ids_map[id] = true
                        found = true
                    else
                        duplicates_table[id] = field[0]
                    end
                end
            end
        end
    end

    if print
        for k,v in @ids_map do
            if v != true
                puts("ID `#{k}` no submission")
            end
        end


        for k,v in duplicates_table do
            if v != true
                puts("ID #{k} in group #{v} duplicated")
            end
        end
    end
end

def random_assign(write)
    team_management(false, true)


    # Fill missing teams first
    for team in @incomplete_teams.keys do
        no_submissions = (@ids_map.select {|k,v| !v}).keys

        if no_submissions.length == 0
            break
        end

        team_size = @teams_map[team].length
        missing = @@minimum_members - team_size
        selected = 0

        if no_submissions.length >= missing
            selected = no_submissions.sample(missing)
        else
            selected = no_submissions.length
        end

        @teams_map[team] += selected
        for member in selected do
            @ids_map[member] = true
        end
    end

    # Form teams from remaining students

    # Check if there is a number that can give whole divisions
    no_submissions = (@ids_map.select {|k,v| !v}).keys
    chosen_size = @@maximum_members
    for size in (@@minimum_members..@@maximum_members).to_a.reverse do
        if no_submissions.length % size == 0
            chosen_size = size
            break
        end
    end


    teams_possible = no_submissions.length / chosen_size

    for i in 1..teams_possible do
        no_submissions = (@ids_map.select {|k,v| !v}).keys

        selected = no_submissions.sample chosen_size
        @teams_map["random_#{i}"] = selected

        for member in selected do
            @ids_map[member] = true
        end
    end

    no_submissions = (@ids_map.select {|k,v| !v}).keys
    for id in no_submissions do
        puts("Cannot assign student `#{id}` to team")
    end


    if write
        check_duplicate_students(true)
        team_management(false, false)

        open('new_teams.csv', 'w') { |f|
            for team,members in @teams_map do
                line = "#{team}"
                for m in members do
                    line += ",#{m}"
                end

                f.puts line

            end
        }

    else
        for k,v in @teams_map do
            puts("TEAM #{k} members #{v}")
        end
    end

end


random_assign(true)
