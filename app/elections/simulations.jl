include("multi_schulze.jl")

using Random

function create_random_ballots(num_candidates::Int, num_voters::Int)
    ballots = Vector{Vector{Vector{Integer}}}(undef, num_voters)

    for i in 1:num_voters
        ballot = Vector{Vector{Integer}}()
        ballots[i] = ballot

        for j in 1:num_candidates
            push!(ballot, [])
        end

        positions = rand(1:num_candidates + 1, num_candidates)

        for j in 1:num_candidates
            if positions[j] <= num_candidates
                push!(ballot[positions[j]], j)
            end
        end
    end

    candidates = Vector{String}(undef, num_candidates)

    for i in 1:num_candidates
        candidates[i] = "Candidate $(i)"
    end

    return candidates, ballots
end

# Presentation simulation

function vote_simulation()
    candidates = ["A", "B", "C", "D", "E"]
    ballots = Vector{Vector{Vector{Integer}}}(undef, 100)
    num_ballots = 0
    default_position = 3

    map_for = Dict("A" => 18,
                    "B" => 11,
                    "C" => 33,
                    "D" => 12,
                    "E" => 7)

    map_against = Dict("A" => 19,
                        "B" => 3,
                        "C" => 60,
                        "D" => 15,
                        "E" => 1)

    while num_ballots < 100 && (sum(values(map_for)) > 0 || sum(values(map_against)) > 0)
        for_vote = get_vote(candidates, map_for, rand(1:100 - num_ballots))
        
        if isempty(for_vote)
            except = nothing
            for_tally = 0
        else
            except = candidates[for_vote[1]]
            for_tally = map_for[except]
        end

        against_vote = get_vote(candidates, map_against, rand(1:100 - num_ballots - for_tally),
                                except)
        ballot = [for_vote, [], [], [], against_vote]
        num_ballots += 1
        ballots[num_ballots] = ballot
    end

    for key in keys(map_against)
        index = 1

        for i in 1:map_against[key]
            while !placed!(ballots[index], findall(x -> x == key, candidates)[1])
                index += 1
            end
        end
    end

    while num_ballots < 100
        num_ballots += 1
        ballots[num_ballots] = [[], [], [], [], []]
    end

    num_candidates = length(candidates)
    pairwise = zeros(Int, num_candidates, num_candidates)

    # Update pairwise matrix based on all ballots
    for ballot in ballots
        update_pairwise(num_candidates, ballot, pairwise, default_position)
    end

    # Get the ranking and scores from Schulze method
    ranking, scores = schulze_ranking(num_candidates, pairwise)

    return ranking, scores, calculate_results(candidates = candidates,
                                ballots = ballots,
                                seats = 100,
                                num_winners = 2,
                                default_position = 3)
end

function get_vote(candidates, map, position, except = nothing)
    if position > sum(values(map)) - get(map, except, 0)
        return Vector{Int}()
    end

    candidate_position = 0
    candidate_index = 0

    while candidate_position < position && candidate_index < length(candidates)
        candidate_index += 1
        
        if candidates[candidate_index] != except
            candidate_position += map[candidates[candidate_index]]
        end
    end

    map[candidates[candidate_index]] -= 1

    return [candidate_index]
end

function placed!(ballot, candidate_index)
    if isempty(findall(x -> x == candidate_index, ballot[1])) &&
        isempty(findall(x -> x == candidate_index, ballot[end]))

        append!(ballot[end], candidate_index)
        
        return true
    else
        return false
    end
end

# Belgian election random simulation

function do_election()
end