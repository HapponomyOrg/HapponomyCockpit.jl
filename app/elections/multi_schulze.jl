"""
    Schulze voting method.
    Adjusted for multiple winners and equal ranking.

    Source: https://en.wikipedia.org/wiki/Schulze_method and https://en.wikipedia.org/wiki/Schulze_STV

    Author: [Happonomy](http://happonomy.org)
"""

# Function to update the pairwise matrix based on a single ballot
function update_pairwise(num_candidates::Int, ballot, pairwise::Matrix{Int}, default_position::Int)
    rank_map = Dict()
    
    # Fill the rank map (candidate -> rank)
    for (i, rank) in enumerate(ballot)
        for candidate in rank
            rank_map[candidate] = i
        end
    end

    # Update the pairwise matrix. The value at pairwise[i, j] is the number of times candidate i wins from candidate j.
    for i in 1:num_candidates
        for j in 1:i - 1
            rank_i = get(rank_map, i, default_position)
            rank_j = get(rank_map, j, default_position)

            if rank_i < rank_j
                pairwise[i, j] += 1
            elseif rank_i > rank_j
                pairwise[j, i] += 1
            end
        end        
    end
end

function calculate_path_strength(num_candidates::Int, pairwise::Matrix{Int})
    path_strength = copy(pairwise)

    # Adjust for transitive wins.
    # For every (i, j) pair check whether i beats j through k.
    # If the weakest of the (i, k), (k, j) paths is stronger than the original (i, j) path
    # then set the strength of the (i, j) path to the weakest of the (i, k), (k, j) paths.
    for i in 1:num_candidates
        for j in 1:num_candidates
            if i != j
                for k in 1:num_candidates
                    if i != k && j != k
                        path_strength[j, k] = max(path_strength[j, k], min(path_strength[j, i], path_strength[i, k]))
                    end
                end
            end
        end
    end

    return path_strength
end

# Enhanced Schulze method implementation with multiple winners and equal ranking
function schulze_ranking(num_candidates::Int, pairwise::Matrix{Int})
    path_strength = calculate_path_strength(num_candidates, pairwise)

    # Handling ties
    candidate_scores = zeros(Float64, num_candidates)

    for i in 1:num_candidates
        for j in 1:i
            if i != j
                if path_strength[i, j] > path_strength[j, i]
                    candidate_scores[i] += 1
                elseif path_strength[j, i] > path_strength[i, j]
                    candidate_scores[j] += 1
                else # path_strength[i, j] == path_strength[j, i]
                    candidate_scores[i] += 0.5
                    candidate_scores[j] += 0.5
                end
            end
        end
    end

    sorted_indices = sortperm(candidate_scores, rev=true)
    return sorted_indices, candidate_scores[sorted_indices]
end

# Convert rankings to seat allocations, distributing seats only among the selected winners
function allocate_seats_among_winners(candidates, ranking, scores, seats, winners)
    selected_winners = ranking[1:winners]
    i = winners + 1

    # Add ties for last place to winners
    while length(selected_winners) < length(ranking) &&
            scores[i] == scores[i - 1]
        push!(selected_winners, ranking[i])
        i += 1
    end

    selected_scores = scores[1:winners]
    
    total_score = sum(selected_scores)
    seat_allocations = Int[]

    # Allocate seats proportionally based on the selected winners' scores
    for i in eachindex(selected_scores)
        selected_seats = round(Int, (selected_scores[i] / total_score) * seats)
        push!(seat_allocations, selected_seats)
    end

    # Allocate the remaining seats, if any, among the winners. Highest score gets an extra seat first.
    remaining_seats = seats - sum(seat_allocations)
    i = 1

    while remaining_seats > 0
        seat_allocations[i] += 1
        remaining_seats -= 1
        i == winners ? i = 1 : i += 1
    end

    return candidates[selected_winners], seat_allocations
end

function calculate_results(;candidates::Vector{String},
                            ballots::Vector{Vector{Vector{Integer}}},
                            seats::Int,
                            num_winners::Int,
                            default_position = length(candidates))
    num_candidates = length(candidates)
    pairwise = zeros(Int, num_candidates, num_candidates)

    # Update pairwise matrix based on all ballots
    for ballot in ballots
        update_pairwise(num_candidates, ballot, pairwise, default_position)
    end

    # Get the ranking and scores from Schulze method
    ranking, scores = schulze_ranking(num_candidates, pairwise)

    # Allocate seats based on ranking and scores, only among the top `winners`
    winners, seat_allocations = allocate_seats_among_winners(candidates,
                                                                ranking,
                                                                scores,
                                                                seats,
                                                                num_winners)

    # Create the results as pairs of winners and their seat allocations.
    # Execo's for last place are grouped in the tuple.
    results = []

    for i in 1:num_winners
        push!(results, ([winners[i]], seat_allocations[i]))
    end

    for i in num_winners + 1:length(winners)
        push!(results[end][1], winners[i])
    end

    return results
end